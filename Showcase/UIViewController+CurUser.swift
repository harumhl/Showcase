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
    // Load in a user's books (by email)
    func loadUserBooks(user: UserClass) {
      var dbRef: DatabaseReference!
      dbRef = Database.database().reference()
      let email = user.email.substring(to: user.email.index(of: "@")!)
      dbRef.child("user").child(email+"/books").observeSingleEvent(of: .value, with: { (snapshot) in
        // Grab the list user's book list
        let userBooks = snapshot.value as? NSDictionary
        if (userBooks != nil) {
            // print("value: ", userBooks!)
            dbRef.child("book").observeSingleEvent(of: .value, with: { (snapshot) in
                // Grab the list of ALL books
                let allBooks = snapshot.value as? NSDictionary
                if (allBooks != nil) {
                    // print("All books: ", allBooks!)
                    // Loop through the user's books and grab the bookKey value
                    for (_, value) in userBooks!{
                        // A user's book entry is a dictionary ('bookID' -> 'bookKey')
                        let userBook = value as! NSDictionary
                        let theUserBookKey = userBook["bookID"]
                        print("Book Key: ", theUserBookKey as Any)
                        
                        // See if we can find the user's book in the main book list.
                        if allBooks![theUserBookKey as Any] != nil {
                            let aUserBook =  allBooks![theUserBookKey!] as! NSDictionary
                            let tempBook = Book()
                            tempBook.ISBN = aUserBook.value(forKey: "BookISBN") as! String
                            user.addBook(b: tempBook)
                            print("cur count ", user.books.count)
                            
                            
                            
                            print ("The acutal book ISBN:", aUserBook.value(forKey: "BookISBN") as Any, "\n")
                        } else {
                            print ("\nInvalid Book!")
                        }
                    }
                }
            })
            
            print("user book count is ", user.books.count)
         }
      })
    }
    
    // Check authentication and grab the currently signed in user.
    func getUser() -> UserClass {
        let curUser = UserClass()
        var email = "heyman"
        let user = Auth.auth().currentUser
        if let user = user {
            curUser.isSignedIn = true
            email = user.email!
            email = email.substring(to: email.index(of: "@")!)
            print("Username: ", email)
            curUser.email = (user.email!)
            print("Current user eMail " + curUser.email)
            // Populate the current user's book list
            loadUserBooks(user: curUser)
        }
        else {
            curUser.isSignedIn = false
        }
        return curUser
    }
}
