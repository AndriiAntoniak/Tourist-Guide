//
//  SignUpViewController.swift
//  TestProject
//
//  Created by ABei on 3/27/18.
//  Copyright © 2018 ABei. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        emailTextField.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        passwordTextField.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        repeatPasswordTextField.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        //
        nameTextField.layer.borderWidth = 1.5
        emailTextField.layer.borderWidth = 1.5
        passwordTextField.layer.borderWidth = 1.5
        repeatPasswordTextField.layer.borderWidth = 1.5
        //
        nameTextField.layer.cornerRadius = 4
        emailTextField.layer.cornerRadius = 4
        passwordTextField.layer.cornerRadius = 4
        repeatPasswordTextField.layer.cornerRadius = 4
        //
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        if passwordTextField.text != repeatPasswordTextField.text {
            let alert = alertNotification(title: "Error", message: "Repeat password again!!!")
            present(alert, animated: true, completion: nil)
        } else if nameTextField.text == "" || emailTextField.text == "" || passwordTextField.text == "" || repeatPasswordTextField.text == "" {
            let alert = alertNotification(title: "Error", message: "Please, fill all gaps!!!")
            present(alert, animated: true, completion: nil)
            } else {
            AuthService.authService.createUser(name: nameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!) {
                if UserDefaults.standard.value(forKey: "uid") != nil {
                    self.performSegue(withIdentifier: "fromSignUpToMap", sender: nil)
                }
            }
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        repeatPasswordTextField.resignFirstResponder()
        return true
    }
}
