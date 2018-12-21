//
//  ProfileDetailVC.swift
//  messagingapp
//
//  Created by Nishita on 08/06/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import Foundation

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SDWebImage

class ProfileDetailVC: UIViewController{
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imgUserProfile: UIImageView!
    @IBOutlet var lblFirstName: UILabel!
    
    let imagePicker = UIImagePickerController()

    @IBAction func btnActionProfileChange(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        let button1 = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: .plain, target: self, action: #selector(HomeVC.addTapped))
        
        self.navigationItem.leftBarButtonItem = button1
        imagePicker.delegate = self
        activityIndicator.startAnimating()
        imgUserProfile.layer.borderWidth = 1.0
        imgUserProfile.layer.masksToBounds = false
        imgUserProfile.layer.borderColor = UIColor.white.cgColor
        imgUserProfile.layer.cornerRadius = imgUserProfile.frame.size.width / 2
        imgUserProfile.clipsToBounds = true
        Database.database().reference()
            .child("users")
            .child(Auth.auth().currentUser!.uid)
            .child("username")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                guard let dict = snapshot.value as? [String:Any] else {
                    print("Error")
                    return
                }
                let firstName = dict["Firstname"] as? String
                let lastName = dict["Lastname"] as? String
                self.lblFirstName.text = firstName! + " " + lastName!
                let imageName = "imgUserProfile"
                let reference = Storage.storage().reference(forURL: "gs://messagingapp-c035f.appspot.com")
                let url = reference.child(Auth.auth().currentUser!.uid).child(imageName)
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
                            self.imgUserProfile.sd_setImage(with: url, placeholderImage: placeholderImage)
                        }
                    }).resume()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                })
            })
    }
    @objc func addTapped(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showSideMenu()
    }
}
extension ProfileDetailVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String: Any])
    {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            
            imgUserProfile.image = image
            activityIndicator.stopAnimating()
            var data = NSData()
            data = UIImageJPEGRepresentation(self.imgUserProfile.image!, 0.8)! as NSData
            let storageRef = Storage.storage().reference()
            let filePath = "\(Auth.auth().currentUser!.uid)/\("imgUserProfile")"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            storageRef.child(filePath).putData(data as Data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
