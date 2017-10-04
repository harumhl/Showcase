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
        var ref2: DatabaseReference!
        ref2 = Database.database().reference()
        let curUser = User()
        var email = "heyman"
        let user = Auth.auth().currentUser
        if let user = user {
            curUser.isSignedIn = true
            email = user.email!
            email = email.substring(to: email.index(of: "@")!)
            print("substring email: ", email)
            curUser.email = (user.email!)
            print("current user email " + curUser.email)
            // Populate the current user's book list
            ref2.child("user").child(email+"/books").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let bookDict = snapshot.value as? NSDictionary
                if (bookDict != nil) {
                    print("value: ", bookDict!)
                    ref2.child("book").observeSingleEvent(of: .value, with: { (snapshot) in
                        let bookDict2 = snapshot.value as? NSDictionary
                        if (bookDict2 != nil) {
                            print("All books: ", bookDict2!)
                            for (key, value) in bookDict!{
                                let eachBook = value as! NSDictionary
                                // var bookObj = bookDict2![id]
                                // let bookKey = value as? [String: AnyObject]
                                let theKey = eachBook["bookID"]
                                print("Book Key: ", theKey)
                                
                                // print("New Value: ", newValue)
                                if var bookObj = bookDict2![theKey] {
                                    let bookObj2 =  bookDict2![theKey] as! NSDictionary
                                    print ("The acutal book:", bookObj2["BookISBN"], "\n")
                                } else {
                                    print ("Invalid Book!")
                                }
                            }
                        }
                    })
                }
            })
        }
        else {
            curUser.isSignedIn = false
        }
        return curUser
    }
}
