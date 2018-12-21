//
//  ViewController.swift
//  messagingapp
//
//  Created by Nishita on 31/05/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import FBSDKLoginKit

class LoginVC: UIViewController {
    
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPwd: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
    }
    @IBAction func btnActionLoginWithFb(_ sender: Any) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((FBSDKAccessToken.current()) != nil){
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                if (error == nil){
                                    let dict = result as! NSDictionary
                                    let firstName = ["Firstname": dict.object(forKey: "first_name") as! String , "Lastname": dict.object(forKey: "last_name")as! String]
                                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                                    Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                                        if error != nil {
                                            return
                                        }
                                        self.ref = Database.database().reference()
                                        let imgDict = dict .object(forKey: "picture") as! NSDictionary
                                        let imgData = imgDict .object(forKey: "data") as! NSDictionary
                                        let img = imgData .object(forKey: "url") as! NSString
                                        if let url = URL(string: img as String) {
                                            var data = try? Data(contentsOf: url)
                                            let image: UIImage = UIImage(data: data!)!
                                            data = UIImageJPEGRepresentation(image, 0.8)! as NSData as Data
                                            let storageRef = Storage.storage().reference()
                                            let filePath = "\(Auth.auth().currentUser!.uid)/\("imgUserProfile")"
                                            let metaData = StorageMetadata()
                                            metaData.contentType = "image/jpg"
                                            storageRef.child(filePath).putData((data)!, metadata: metaData){(metaData,error) in
                                                if let error = error {
                                                    print(error.localizedDescription)
                                                    return
                                                }
                                            }
                                        }
                                    self.ref.child("users").child(Auth.auth().currentUser!.uid).setValue(["username": firstName])
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        appDelegate.sideMenu()
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func btnActionForgetPwd(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                if error != nil{
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }else {
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            })
        }))
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
    
    @IBAction func btnAction(_ sender: Any) {
        if self.txtUsername.text == "" || self.txtPwd.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter Email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().signIn(withEmail: self.txtUsername.text!, password: self.txtPwd.text!) { (user, error) in
                if error == nil {
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
    @IBAction func btnLogin(_ sender: Any) {
        let vc = objSignUpSB.instantiateViewController(withIdentifier: "SignUpVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

