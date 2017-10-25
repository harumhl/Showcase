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
    // Check authentication and grab the currently signed in user.
    func getUser() -> UserClass {
        let curUser = UserClass()
        var email = ""
        let user = Auth.auth().currentUser
        if let user = user {
            print("starting...")
            email = user.email!
            email = email.substring(to: email.index(of: "@")!)
            curUser.isSignedIn = true
            curUser.email = (user.email!)
        }
        else {
            curUser.isSignedIn = false
        }
        return curUser
    }
}
