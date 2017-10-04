//
//  User.swift
//  Showcase
//
//  Created by Brandon Ellis on 9/20/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import Foundation

class User {
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
    
    func loadPrevBooks() {
        
    }
    
    func addBook(b: Book) {
        books.append(b)
    }
    
}
