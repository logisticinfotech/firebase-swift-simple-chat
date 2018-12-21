//
//  ContactVC.swift
//  messagingapp
//
//  Created by Nishita on 21/06/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit
import Contacts
import Firebase
class ContactVC: UIViewController{

    @IBOutlet var tblContact: UITableView!
    
    var ref: DatabaseReference!

    let arrContactList = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        let button1 = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: .plain, target: self, action: #selector(ContactVC.addTapped))
        self.navigationItem.leftBarButtonItem  = button1
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            guard granted else {
                let alert = UIAlertController(title: "Can't access contact", message: "Please go to Settings -> MyApp to enable contact permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor] )
            
            request.sortOrder = CNContactSortOrder.givenName
            var cnContacts = [CNContact]()
            
            do {
                try store.enumerateContacts(with: request){
                    (contact, cursor) -> Void in
                    cnContacts.append(contact)
                }
            } catch let error {
                NSLog("Fetch contact error: \(error)")
            }
            
            for contact in cnContacts {
                
                let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
                (contact.phoneNumbers[0].value ).value(forKey: "digits")
                
                self.arrContactList.add(fullName)
            }
            
            self.ref = Database.database().reference()
            let data = NSData()
            
            let storageRef = Storage.storage().reference()
            
            let filePath = "\(Auth.auth().currentUser!.uid)/\("Contacts")"
            let metaData = StorageMetadata()

            storageRef.child(filePath).putData(data as Data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
            DispatchQueue.main.async {
                self.tblContact.reloadData()
            }
        })
    }
    @objc func addTapped(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showSideMenu()
    }
   
}
extension ContactVC : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrContactList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ContactCell
        cell.lblName.text = (arrContactList.object(at: indexPath.row) as! String)
        return cell
    }
}
