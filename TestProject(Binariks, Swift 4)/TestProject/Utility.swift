//
//  Utility.swift
//  TestProject
//
//  Created by ABei on 3/27/18.
//  Copyright © 2018 ABei. All rights reserved.
//

import Foundation
import UIKit

func alertNotification(title: String, message: String) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    return alertController
}
