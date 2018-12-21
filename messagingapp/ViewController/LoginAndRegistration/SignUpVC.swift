//
//  SignUpVC.swift
//  messagingapp
//
//  Created by Nishita on 01/06/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class SignUpVC: UIViewController{
    
    @IBOutlet var imgUserProfile: UIImageView!
    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPwd: UITextField!
  
    let storage = Storage.storage()
    var ref: DatabaseReference!
    let data = Data()
    let imagePicker = UIImagePickerController()
    
    @IBAction func btnAction(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.title = "Registration"
        imgUserProfile.image = #imageLiteral(resourceName: "User")
        imgUserProfile.layer.borderWidth = 1.0
        imgUserProfile.layer.masksToBounds = false
        imgUserProfile.layer.borderColor = UIColor.white.cgColor
        imgUserProfile.layer.cornerRadius = imgUserProfile.frame.size.width / 2
        imgUserProfile.clipsToBounds = true
    }
    
    @IBAction func btnSignUpAction(_ sender: Any) {
        if txtFirstName.text == "" && txtLastName.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter Firstname & Lastname", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
        if txtEmail.text == ""{
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
        if (self.imgUserProfile.image == #imageLiteral(resourceName: "User")){
            let alert = UIAlertController(title: "Alert", message: "Please Select Profile Picture", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPwd.text!) { (user, error) in
                if error == nil {
                    self.ref = Database.database().reference()
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
                    let fullname = ["Firstname": self.txtFirstName.text! , "Lastname": self.txtLastName.text!]
                    self.ref.child("users").child((user?.uid)!).setValue(["username": fullname])
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.sideMenu()
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String: Any])
    {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            imgUserProfile.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
