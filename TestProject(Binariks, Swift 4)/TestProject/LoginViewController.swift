//
//  LoginViewController.swift
//  TestProject
//
//  Created by ABei on 3/27/18.
//  Copyright © 2018 ABei. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var somePhotoImageView: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    //
    @IBOutlet weak var loginStakView: UIStackView!
    //
    
    var facebookLoginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginButton.delegate = self
        facebookLoginButton.frame.size.width = view.frame.width * (2/3)
        facebookLoginButton.frame.size.height = passwordTextField.frame.height
        facebookLoginButton.center = CGPoint(x: view.frame.midX, y: view.frame.midY - 1.5 + loginStakView.frame.height)
        view.addSubview(facebookLoginButton)
        emailTextField.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        passwordTextField.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        emailTextField.layer.borderWidth = 1.5
        passwordTextField.layer.borderWidth = 1.5
        emailTextField.layer.cornerRadius = 4
        passwordTextField.layer.cornerRadius = 4
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.value(forKey: "uid") != nil {
            print("uid is exist")
            let userID = Auth.auth().currentUser?.uid
            AuthService.authService.dataBaseReference.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.emailTextField.text = value!["email"] as? String
                self.passwordTextField.text = value!["password"] as? String
            }, withCancel: { (error) in
                print("ERRORR")
            })
        } else {
            print("UID isnt exist")
        }
    }
    
    @IBAction func signUPButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "fromLoginToSignUp", sender: nil)
    }
    
    @IBAction func signInButtonAction(_ sender: UIButton) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            let alert = alertNotification(title: "Error", message: "Please fill all gaps")
            present(alert, animated: true, completion: nil)
        } else {
            AuthService.authService.logIn(email: emailTextField.text!, password: passwordTextField.text!) {
                if  UserDefaults.standard.value(forKey: "uid") != nil {
                    let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let mapVC = storyBoard.instantiateViewController(withIdentifier: "mapVC")
                    self.present(mapVC, animated: true, completion: nil)
                } else {
                    let alert = alertNotification(title: "Error", message: "incorrect data")
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("ERROR. \(error.localizedDescription)")
        } else if result.isCancelled {
            print("WAS CANCELED")
        } else {
            if FBSDKAccessToken.current() != nil {
                let accessToken = FBSDKAccessToken.current().tokenString
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken!)
                Auth.auth().signIn(with: credential, completion: {(user, error) in
                    if error != nil {
                        print("ERROR. \(String(describing: error?.localizedDescription))")
                    } else {
                        if let provider = user?.providerID {
                            let userInfo = ["provider" : provider, "facebookUser" : user?.email]
                            let userFacebookRef = AuthService.authService.dataBaseReference.child("Users").child((user?.uid)!)
                            userFacebookRef.setValue(userInfo) { (error, ref) in
                                if error != nil {
                                    print("error. \(String(describing: error?.localizedDescription))")
                                } else {
                                    UserDefaults.standard.set(user?.uid, forKey: "facebookUID")
                                    UserDefaults.standard.set(nil, forKey: "uid")
                                    let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let mapVC = storyBoard.instantiateViewController(withIdentifier: "mapVC")
                                    self.present(mapVC, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                })
            } else {
                print("current token is NIL")
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        UserDefaults.standard.set(nil, forKey: "facebookUID")
    }
}
