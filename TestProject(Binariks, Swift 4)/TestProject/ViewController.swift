//
//  ViewController.swift
//  TestProject
//
//  Created by ABei on 3/27/18.
//  Copyright © 2018 ABei. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        //
        let someVar = Database.database().reference()
        
        let someNote = someVar.ref.child("here")
        
        someNote.updateChildValues(["1":"11", "2":"22", "3":"33"])
        print("1233211123")
        //
        
        
    }

  
}

