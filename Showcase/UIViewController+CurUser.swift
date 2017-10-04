//
//  UIViewController+CurUser.swift
//  Showcase
//
//  Created by guillermo_lopez6988 on 10/4/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import Foundation
import Swift
import UIKit
import Firebase

extension UIViewController {
    func getUser() -> User {
        var curUser = User()
        
        var email = "heyman"
        
        let user = Auth.auth().currentUser
        if let user = user {
            email = user.email!
            email = email.substring(to: email.index(of: "@")!)
            print("substring email: ", email)
            
            curUser.email = (user.email!)
            print("current user email " + curUser.email)
        }
        
        
        return curUser
    }
}
