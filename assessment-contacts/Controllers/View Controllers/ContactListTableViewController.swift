//
//  ContactListTableViewController.swift
//  assessment-contacts
//
//  Created by Andrew Elliott on 4/15/22.
//

import UIKit

class ContactListTableViewController: UITableViewController {

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ContactController.shared.fetchContacts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.shared.contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        cell.textLabel?.text = ContactController.shared.contacts[indexPath.row].name
        cell.detailTextLabel?.text = ContactController.shared.contacts[indexPath.row].phoneNumber
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Call") { (action, view, completion) in
            
            let phoneNumber = ContactController.shared.contacts[indexPath.row].phoneNumber
            
            guard let url = URL(string: "tel://\(phoneNumber)"),
                  UIApplication.shared.canOpenURL(url) else { return }
            
            UIApplication.shared.open(url)
        }
        
        action.backgroundColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
        return UISwipeActionsConfiguration(actions: [action])
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ContactController.shared.delete(contact: ContactController.shared.contacts[indexPath.row]) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
              let indexPath = tableView.indexPathForSelectedRow,
              let destination = segue.destination as? ContactDetailViewController else { return }
        
        if identifier == "toContactDetail" {
            destination.contact = ContactController.shared.contacts[indexPath.row]
        }
    }
}
