//
//  Review.swift
//  Showcase
//
//  Created by ellisbrandon20 on 10/18/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import Foundation

class Review{
    var title: String
    var rating: Double
    var date: String
    var review: String
    
    
    init(){
        title = "Title Not Found"
        rating = 0.0
        date = "Date Not Found"
        review = "No Review Text"
    }
    
    init(_title: String, _rating: Double, _date: String, _review: String){
        self.title = _title
        self.rating = _rating
        self.date = _date
        self.review = _review
    }
    
}
