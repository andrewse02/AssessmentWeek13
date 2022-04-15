//
//  Contact.swift
//  assessment-contacts
//
//  Created by Andrew Elliott on 4/15/22.
//

import CloudKit

struct ContactConstants {
    static let RecordType = "Contact"
    static let nameKey = "name"
    static let phoneNumberKey = "phone_number"
    static let emailAddressKey = "email_address"
}

class Contact {
    
    // MARK: - Properties
    
    var name: String
    var phoneNumber: String
    var emailAddress: String
    var ckRecordID: CKRecord.ID
    
    init(name: String, phoneNumber: String, emailAddress: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.ckRecordID = ckRecordID
    }
    
}

extension Contact {
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[ContactConstants.nameKey] as? String else { return nil }
        guard let phoneNumber = ckRecord[ContactConstants.phoneNumberKey] as? String else { return nil }
        guard let emailAddress = ckRecord[ContactConstants.emailAddressKey] as? String else { return nil }
        
        self.init(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress, ckRecordID: ckRecord.recordID)
    }
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool { return lhs.ckRecordID == rhs.ckRecordID }
    
    
}

extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: ContactConstants.RecordType, recordID: contact.ckRecordID)
        self.setValue(contact.name, forKey: ContactConstants.nameKey)
        self.setValue(contact.phoneNumber, forKey: ContactConstants.phoneNumberKey)
        self.setValue(contact.emailAddress, forKey: ContactConstants.emailAddressKey)
    }
}
