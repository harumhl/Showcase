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
    func loadUserBooks(user: UserClass, callback: @escaping ((_ data:[Book]) -> Void)) {
      var dbRef: DatabaseReference!
      var userBookList = [Book]()
      dbRef = Database.database().reference()
      let email = user.email.substring(to: user.email.index(of: "@")!)
      dbRef.child("user").child(email+"/books").observe(DataEventType.value, with: { (snapshot) in
        // Grab the list user's book list
        let userBooks = snapshot.value as? NSDictionary
        if (userBooks != nil) {
            dbRef.child("book").observe(DataEventType.value, with: { (snapshot2) in
                // Grab the list of ALL books
                let allBooks = snapshot2.value as? NSDictionary
                if (allBooks != nil) {
                    // Loop through the user's books and grab the bookKey value
                    // A user's book entry is a dictionary ('bookID' -> 'bookKey')
                    for (_, value) in userBooks!{
                        // See if we can find the user's book in the main book list.
                        let userBook = value as! NSDictionary
                        let theUserBookKey = userBook["bookID"]
                        if allBooks![theUserBookKey as Any] != nil {
                            print("Book Key: ", theUserBookKey as Any)
                            let tempBook = Book()
                            let aUserBook = allBooks![theUserBookKey!] as! NSDictionary
                            tempBook.ISBN = aUserBook.value(forKey: "BookISBN") as! String
                            // user.addBook(b: tempBook)
                            userBookList.append(tempBook)
                            // print("cur count ", user.books.count)
                            // print("The acutal book ISBN:", aUserBook.value(forKey: "BookISBN") as Any, "\n")
                        } else {
                            // print("\nInvalid Book!")
                        }
                    }
                    callback(userBookList)
                }
            })
         }
      })
      // This isn't being called after our DB read, it's being call before.
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
            // print("Username: ", email)
            curUser.email = (user.email!)
            // print("Current user eMail " + curUser.email)
            // Populate the current user's book list
            // The callback ensures that the data is loaded before we continue on
            loadUserBooks(user: curUser, callback: { (data:[Book]) -> Void in
                for book in data {
                    print("Book ISBN: ", book.ISBN + "\n")
                    curUser.addBook(b: book)
                }
                // self.printUserBooks(bookList: curUser.books)
                print("Finished Loading, the book count is ", data.count)
                self.finalizeUserBooks(user: curUser, bookList: data)
            })
        }
        else {
            curUser.isSignedIn = false
        }
        return curUser
    }
    
    func finalizeUserBooks(user: UserClass, bookList: Array<Book>) {
        print("Printing user books...")
        for book in bookList {
            user.addBook(b: book)
            print ("Book: ", book, "\n")
        }
    }
}
