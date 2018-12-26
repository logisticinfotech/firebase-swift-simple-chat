//
//  ProfileVC.swift
//  messagingapp
//
//  Created by Nishita on 08/06/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC : UIViewController{
    
    var items  = ["Home","Contact","Chat", "Profile", "Logout"]
   
    var arrImg = [UIImage(named: "Home"),UIImage(named: "Contact"), UIImage(named: "Chat"), UIImage(named: "Group"), UIImage(named: "Profile"), UIImage(named: "Logout")]
    
    @IBOutlet var tblSideMenu: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button1 = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: .plain, target: self, action: #selector(HomeVC.addTapped))
        self.navigationItem.leftBarButtonItem = button1
    }
    
    @objc func addTapped(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showSideMenu()
    }
}
extension ProfileVC: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ProfileCell
        cell.lblSideMenu.text = items[indexPath.row]
        cell.imgMenu.image = arrImg[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let navMain = objHomeSideSB.instantiateViewController(withIdentifier: "navHomeSide") as! UINavigationController
            
            appDelegate.objSideMenu.centerViewController = navMain
            appDelegate.showSideMenu()
        }
        if indexPath.row == 1
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let navMain = objContactSB.instantiateViewController(withIdentifier: "navContact") as! UINavigationController
            
            appDelegate.objSideMenu.centerViewController = navMain
            appDelegate.showSideMenu()
        }
        else if indexPath.row == 2
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let navMain = objHomeSB.instantiateViewController(withIdentifier: "navMain") as! UINavigationController
            
            appDelegate.objSideMenu.centerViewController = navMain
            appDelegate.showSideMenu()
        }
//        else if indexPath.row == 3
//        {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            let navMain = objGroupSB.instantiateViewController(withIdentifier: "navGroup") as! UINavigationController
//            appDelegate.objSideMenu.centerViewController = navMain
//            appDelegate.showSideMenu()
//
//        }
        else if indexPath.row == 3
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let navMain = objProfileDetailSB.instantiateViewController(withIdentifier: "navDetail") as! UINavigationController
            
            appDelegate.objSideMenu.centerViewController = navMain
            appDelegate.showSideMenu()
        }
        else if indexPath.row == 4 {
            try! Auth.auth().signOut()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logOutSuccess()
        }
    }
}
