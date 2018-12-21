//
//  GroupMenuVC.swift
//  messagingapp
//
//  Created by Nishita on 04/09/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit
import Firebase
class GroupMenuVC: UIViewController {

    let arrUserList = NSMutableArray()
    let arr = NSMutableArray()
    
    
    @IBOutlet weak var viewCreateGroup: UIView!
    @IBOutlet weak var tblGroupList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Groups"
        self.viewCreateGroup.isHidden = true
        let button1 = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: .plain, target: self, action: #selector(HomeVC.addTapped))
        self.navigationItem.leftBarButtonItem = button1
        let ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value, with:  { (snapshot) in
            if snapshot.exists()
            {
                if let fruitPost = snapshot.value as? Dictionary<String,AnyObject>
                {
                    for(key, value) in fruitPost {
                        if let fruitData = value as? Dictionary<String,AnyObject> {
                            
                            if(Auth.auth().currentUser!.uid != key){
                                let dict = NSMutableDictionary()
                                dict.setObject(key, forKey:"firebaseId" as NSCopying)
                                dict.setObject((fruitData["username"] as! NSDictionary).value(forKey: "Firstname")!, forKey: "Firstname" as NSCopying)
                                dict.setObject((fruitData["username"] as! NSDictionary).value(forKey: "Lastname")!, forKey: "Lastname" as NSCopying)
                                self.arrUserList.add(dict)
                            }
                        }
                    }
                }
                print(self.arrUserList)
                self.tblGroupList.reloadData()
            }
        })
    }
    
    @objc func addTapped(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showSideMenu()
    }
    @objc func btnSelect(sender : UIButton){
        print("button click")
    }
    
    @IBAction func onClickCreateGroup(_ sender: Any) {
        if self.viewCreateGroup.isHidden == false{
            self.viewCreateGroup.isHidden = true
        }
        else{
            self.viewCreateGroup.isHidden = false
        }
    }
}
extension GroupMenuVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! GroupListCell
        let dict = arrUserList.object(at: indexPath.row) as! NSDictionary
        
        cell.lblUserName.text = "\(String(describing: dict.object(forKey: "Firstname")!))" + " " + "\(String(describing: dict.object(forKey: "Lastname")!))"
        cell.btnSelect.addTarget(self, action: #selector(self.btnSelect(sender:)), for: .touchUpInside);

        let imagePath = dict.object(forKey: "firebaseId")
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
                    cell.imgUser.layer.borderWidth = 1.0
                    cell.imgUser.layer.masksToBounds = false
                    cell.imgUser.layer.borderColor = UIColor.white.cgColor
                    cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.width / 2
                    cell.imgUser.clipsToBounds = true
                    cell.imgUser.sd_setImage(with: url, placeholderImage: placeholderImage)
                }
            }).resume()
        })
        return cell
    }
}
