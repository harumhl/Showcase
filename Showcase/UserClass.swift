//
//  UserClass.swift
//  Showcase
//
//  Created by Brandon Ellis on 9/20/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import Foundation
import Firebase

typealias BookArrayClosure = (_ bookArray: [Book]?)->()

class UserClass {
    var firstName: String
    var lastName: String
    var email: String
    var books: Array<Book>
    var isSignedIn: Bool
    //var reviews = array of Review Objects
    
    init() {
        firstName = ""
        lastName = ""
        email = ""
        books = []
        isSignedIn = false
    }
    
    init(fname: String, lname: String, e: String) {
        firstName = fname;
        lastName = lname;
        email = e;
        books = []
        isSignedIn = false
    }
    
    func loadPrevBooks(completionHandler: @escaping BookArrayClosure) {
        var dbRef: DatabaseReference!
        dbRef = Database.database().reference()
        var emailSub = email.substring(to: email.index(of: "@")!)
        
        dbRef.child("user").child(emailSub+"/books").observe(DataEventType.value, with: { (snapshot) in
            // Grab the list user's book list (UniqueKey -> bookID)
            let userBooks = snapshot.value as? NSDictionary
            
            if (userBooks == nil) { return }
            
            dbRef.child("book").observe(DataEventType.value, with: { (snapshot2) in
             // grab the list of all books
                let allBooks = snapshot2.value as? NSDictionary
                if (allBooks == nil) { return }
                
                // Loop through the user's books and grab the bookKey value
                // A user's book entry is a dictionary ('bookID' -> 'bookKey')
                for (_, value) in userBooks!{
                    // See if we can find the user's book in the main book list.
                    let userBook = value as! NSDictionary
                    let theUserBookKey = userBook["bookID"]
                    
                    // find the users book from the set of all books
                    if allBooks![theUserBookKey as Any] != nil {
                        let tempBook = Book()
                        let aUserBook = allBooks![theUserBookKey!] as! NSDictionary
                        tempBook.ISBN = aUserBook.value(forKey: "BookISBN") as! String
                        self.addBook(b: tempBook)
                    
                    }
                }
            })
            
            if (self.books.isEmpty) {
                completionHandler(nil)
            }
            else {
                completionHandler(self.books)
            }
            
        })
        
    }
    
    func addBook(b: Book) {
        books.append(b)
        print("Appended book with ISBN: ", b.ISBN)
    }
    
    func getNumBooks() -> Int{
        return books.count
    }
    
}
