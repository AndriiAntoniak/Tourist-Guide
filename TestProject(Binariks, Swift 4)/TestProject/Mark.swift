//
//  Mark.swift
//  TestProject
//
//  Created by ABei on 3/28/18.
//  Copyright © 2018 ABei. All rights reserved.
//

import Foundation
import Firebase

class Marker {
    let name : String!
    let latitude : Double!
    let longitude : Double!
    let timeID : String!
    
    init(name : String, latitude : Double, longitude : Double, timeID : String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.timeID = timeID
    }
}

