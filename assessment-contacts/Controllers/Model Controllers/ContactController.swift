//
//  ContactController.swift
//  assessment-contacts
//
//  Created by Andrew Elliott on 4/15/22.
//

import CloudKit

class ContactController {
    
    // MARK: - Properties
    
    static let shared = ContactController()
    var contacts: [Contact] = []
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - CRUD Functions
    
    func createContact(name: String, phoneNumber: String?, emailAddress: String?, completion: @escaping (_ result: Result<Contact?, ContactError>) -> Void) {
        let newContact = Contact(name: name, phoneNumber: phoneNumber ?? "", emailAddress: emailAddress ?? "")
        
        save(contact: newContact, completion: completion)
    }
    
    func save(contact: Contact, completion: @escaping (_ result: Result<Contact?, ContactError>) -> Void) {
        let ckRecord = CKRecord(contact: contact)
        privateDB.save(ckRecord) { record, error in
            if let error = error {
                completion(.failure(.thrownError(error)))
            } else {
                guard let record = record,
                      let savedContact = Contact(ckRecord: record) else { return }
                self.contacts.append(savedContact)
                completion(.success(savedContact))
            }
        }
    }
    
    func fetchContacts(completion: @escaping (_ result: Result<[Contact]?, ContactError>) -> Void) {
        let query = CKQuery(recordType: ContactConstants.RecordType, predicate: NSPredicate(value: true))
        var operation = CKQueryOperation(query: query)
        
        var fetchedRecords: [CKRecord] = []
        
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                fetchedRecords.append(record)
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if let cursor = cursor {
                    let nextOperation = CKQueryOperation(cursor: cursor)
                    nextOperation.queryResultBlock = operation.queryResultBlock
                    nextOperation.resultsLimit = operation.resultsLimit
                    nextOperation.recordMatchedBlock = operation.recordMatchedBlock
                    operation = nextOperation
                    self.privateDB.add(nextOperation)
                } else {
                    let fetchedContacts = fetchedRecords.compactMap({ Contact(ckRecord: $0) })
                    self.contacts = fetchedContacts
                    return completion(.success(fetchedContacts))
                }
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        
        operation.qualityOfService = .userInteractive
        privateDB.add(operation)
    }
    
    func update(contact: Contact, name: String, phoneNumber: String?, emailAddress: String?, completion: @escaping (_ result: Result<Contact?, ContactError>) -> Void) {
        contact.name = name
        contact.phoneNumber = phoneNumber ?? ""
        contact.emailAddress = emailAddress ?? ""
        let record = CKRecord(contact: contact)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                return completion(.success(contact))
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        
        privateDB.add(operation)
    }
    
    func delete(contact: Contact, completion: @escaping (_ result: Result<Bool, ContactError>) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.ckRecordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                guard let index = self.contacts.firstIndex(of: contact) else { return completion(.failure(.noData)) }
                self.contacts.remove(at: index)
                
                return completion(.success(true))
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        
        privateDB.add(operation)
    }
}
