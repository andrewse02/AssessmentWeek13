//
//  ContactDetailViewController.swift
//  assessment-contacts
//
//  Created by Andrew Elliott on 4/15/22.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var contact: Contact? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        phoneNumberTextField.delegate = self
        emailAddressTextField.delegate = self
    }

    // MARK: - Actions
    
    @IBAction func mainViewTapped(_ sender: Any) {
        nameTextField.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
        emailAddressTextField.resignFirstResponder()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let nameText = nameTextField.text,
              !nameText.isEmpty else {
            nameTextField.layer.borderColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
            nameTextField.layer.borderWidth = 1
            
            return
        }
        
        if let contact = contact {
            ContactController.shared.update(contact: contact, name: nameText, phoneNumber: phoneNumberTextField.text, emailAddress: emailAddressTextField.text) { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            ContactController.shared.createContact(name: nameText, phoneNumber: phoneNumberTextField.text, emailAddress: emailAddressTextField.text) { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func updateViews() {
        guard let contact = contact else { return }
        
        nameTextField.text = contact.name
        phoneNumberTextField.text = contact.phoneNumber
        emailAddressTextField.text = contact.emailAddress
    }
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        
        for character in mask where index < numbers.endIndex {
            if character == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(character)
            }
        }
        
        return result
    }
}

extension ContactDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        if textField == phoneNumberTextField {
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            textField.text = format(with: "XXX-XXX-XXXX", phone: newString)
        } else {
            textField.text = (text as NSString).replacingCharacters(in: range, with: string)
        }
        
        return false
    }
}
