//
//  SuccessVC.swift
//  messagingapp
//
//  Created by Nishita on 31/05/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit
import Firebase
class HomeVC: UIViewController{
    
    @IBOutlet var tblUserList: UITableView!
    
    let arrUserList = NSMutableArray()
    let arr = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat"
       let button1 = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: .plain, target: self, action: #selector(HomeVC.addTapped))
        self.navigationItem.leftBarButtonItem = button1
        let ref = Database.database().reference()
        ref.child("Chats").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with:  { (snapshot) in
            if snapshot.exists()
            {
                if let fruitPost = snapshot.value as? Dictionary<String,AnyObject>
                {
                    for(key, _) in fruitPost {
                        if(Auth.auth().currentUser!.uid != key){
                            let dict = NSMutableDictionary()
                            dict.setObject(key, forKey:"firebaseId" as NSCopying)
                            self.arrUserList.add(dict)
                        }
                    }
                }
                print(self.arrUserList)
                self.tblUserList.reloadData()
            }
        })
    }
    @objc func addTapped(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showSideMenu()
    }
}
extension HomeVC : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! HomeTableViewCell
        
        let dict = arrUserList.object(at: indexPath.row) as! NSDictionary
        
        let firebaseId = dict.object(forKey: "firebaseId")
        
        Database.database().reference()
            .child("users")
            .child(firebaseId as! String)
            .child("username")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                
                if let dict1 = snapshot.value as? NSMutableDictionary
                {
                    dict1.setObject(firebaseId!, forKey: "firebaseId" as NSCopying)
                    
                    let firstName = dict1["Firstname"] as? String
                    self.arr.add(dict1)
                    
                    cell.lblUserName.text = firstName!
                }
            })
        let imagePath = firebaseId
        let imageName = "imgUserProfile"
        
        let reference = Storage.storage().reference(forURL: "gs://messagingapp-c035f.appspot.com")
        let url = reference.child(imagePath as! String).child(imageName)
        let placeholderImage = UIImage(named: "placeholder.jpg")
        
        url.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                DispatchQueue.main.async {
                    cell.imgUserProfile.layer.borderWidth = 1.0
                    cell.imgUserProfile.layer.masksToBounds = false
                    cell.imgUserProfile.layer.borderColor = UIColor.white.cgColor
                    cell.imgUserProfile.layer.cornerRadius = cell.imgUserProfile.frame.size.width / 2
                    cell.imgUserProfile.clipsToBounds = true
                    cell.imgUserProfile.sd_setImage(with: url, placeholderImage: placeholderImage)
                }
            }).resume()
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = objChatSB.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.dict = arr.object(at: indexPath.row) as! NSDictionary
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Alert", message: "Are you sure want to Delete Chat?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                let dict1 = self.arrUserList.object(at: indexPath.row) as! NSDictionary
                
                let userRef = Database.database().reference().child("Chats")
                    .child(Auth.auth().currentUser!.uid).child(dict1.object(forKey: "firebaseId") as! String)
                userRef.removeValue()
                self.arrUserList.removeObject(at: indexPath.row)
                
                self.tblUserList.reloadData()
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
