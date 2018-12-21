//
//  HomeSideVC.swift
//  messagingapp
//
//  Created by Nishita on 18/06/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit
import Firebase
class HomeSideVC: UIViewController{

    @IBOutlet var tblUserList: UITableView!
    
    let arrUserList = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.tblUserList.separatorStyle = .none
        let button1 = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: .plain, target: self, action: #selector(HomeSideVC.addTapped))
        
        self.navigationItem.leftBarButtonItem  = button1
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
                self.tblUserList.reloadData()
            }
        })
    }
    @objc func addTapped(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
       appDelegate.showSideMenu()
    }

}
extension HomeSideVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! HomeSideVcCell
        
        let dict = arrUserList.object(at: indexPath.row) as! NSDictionary
        
        cell.lblUsername.text = "\(String(describing: dict.object(forKey: "Firstname")!))" + " " + "\(String(describing: dict.object(forKey: "Lastname")!))"
        
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = objChatSB.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.dict = arrUserList.object(at: indexPath.row) as! NSDictionary
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
