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
    var ISBN: String
    var price: Double
    var imageURL: String
    //var reviews = array of Review Objects
    
    init() {
        title = "N/A"
        ISBN = "N/A"
        price = 0.0
        imageURL = "N/A"
        //reviews = "N/A"
    }
}
