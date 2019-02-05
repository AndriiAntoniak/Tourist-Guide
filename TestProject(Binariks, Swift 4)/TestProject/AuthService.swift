//
//  AuthService.swift
//  TestProject
//
//  Created by ABei on 3/27/18.
//  Copyright © 2018 ABei. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class AuthService {
    
    static let authService = AuthService()
    
    var dataBaseReference: DatabaseReference! {
        return Database.database().reference()
    }
    
    private init() {}
    
    func logIn(email: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                print("NotError: \(String(describing: error))")
                UserDefaults.standard.set(user?.user.uid, forKey: "uid")
                completion()
            } else {
                print("IsError: \(String(describing: error))")
            }
        })
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(nil, forKey: "uid")
        } catch let signOutError {
            print("cannot signout!!!\(signOutError)")
        }
    }
    
    func createUser(name: String, email: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                self.saveUserInfo(name: name, email: email, password: password, user: user!.user) {
                    completion()
                }
            } else {
                print("error. \(String(describing: error?.localizedDescription))")
            }
        })
    }
    
    func saveUserInfo(name: String, email: String, password: String, user: User, completion: @escaping () -> Void) {
        let userInfo = ["userName" : name,
                        "email" : email,
                        "password" : password]
        let userRef = dataBaseReference.child("Users").child(user.uid)
        userRef.setValue(userInfo) { (error, ref) in
            if error == nil {
                UserDefaults.standard.set(user.uid, forKey: "uid")
                self.logIn(email: email, password: password) {
                    completion()
                }
            } else {
                print("error. Cannot save user. \(String(describing: error?.localizedDescription))")
            }
        }
    }
}
