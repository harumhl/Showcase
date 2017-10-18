//
//  Book.swift
//  Showcase
//
//  Created by Brandon Ellis on 10/3/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import Foundation

/**
 
Book class will store all relevant information that we need to display on the PostScanViewController
 
 The following data will also be stored in Firebase:
 - title
 - ISBN
 - Price
 - imageUrl
 
**/


class Book {
    var title: String
    var author: String
    var ISBN: String
    var price: String
    var imageURL: String
    var rating: Double
    var reviewURL: String
    var DateCreatedAt: String
    var SecondsSince1970: UInt
    //var reviews = array of Review Objects
    
    init() {
        title = "N/A"
        author = "N/A"
        ISBN = "N/A"
        price = "Price Not Available"
        imageURL = "N/A"
        rating = -1
        reviewURL = "N/A"
        DateCreatedAt = "N/A"
        SecondsSince1970 = 0
        //reviews = "N/A"
    }
    
    init(_title: String, _author:String, _ISBN: String, _price: String, _imageURL: String, _rating: Double, _reviewURL: String, _DateCreatedAt: String, _SecondsSince1970: UInt){
        self.title = _title
        self.author = _author
        self.ISBN = _ISBN
        self.price = _price
        self.imageURL = _imageURL
        self.rating = _rating
        self.reviewURL = _reviewURL
        self.DateCreatedAt = _DateCreatedAt
        self.SecondsSince1970 = UInt(_SecondsSince1970)
    }
}
