//
//  DBUtils.swift
//  Showcase
//
//  Created by ellisbrandon20 on 11/10/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import Foundation
import Firebase


func loadBookReview(tempBook: Book){
    // Set Firebase DB reference
    var ref = Database.database().reference()
    ref.child("review").observe(DataEventType.value, with: { (snapshot) in
        // grab all book reviews
        let allBooks = snapshot.value as? NSDictionary
        if(allBooks == nil) { return }
        
        // loop through and try to find the match for the book currently being searched
        for (_isbn, _reviews) in allBooks! {
            let isbn_db = _isbn as! String
            if(isbn_db == tempBook.ISBN){
                var tmpReview = Review()
                // read the reviews and append to reviews array
                for (_key, review) in _reviews as! NSDictionary{
                    tmpReview.title = (review as! NSDictionary)["reviewTitle"] as! String
                    tmpReview.date = (review as! NSDictionary)["reviewDate"] as! String
                    tmpReview.review = (review as! NSDictionary)["reviewText"] as! String
                    tmpReview.rating = (review as! NSDictionary)["reviewRating"] as! Double
                    tempBook.reviews.append(tmpReview)
                }
            }
        }
    })
    
}


func isReviewInDB(bookData: Book) -> Bool {
    // using the bookData.reviewURL check if the review object already exists in the database
    var foundBook = false
    // Set Firebase DB reference
    var ref = Database.database().reference()
    ref.child("review").observe(DataEventType.value, with: { (snapshot) in
        // grab all book reviews
        let allBooks = snapshot.value as? NSDictionary
        if(allBooks == nil) { return }
        
        // loop through and try to find the match for the book currently being searched
        for (isbn, _) in allBooks! {
            let isbn_db = isbn as! String
            print("isbn_db: \(isbn)")
            if(isbn_db == bookData.ISBN){
                print("found ISBN in ReviewDB no need to write to DB")
                foundBook = true
                return
            }
        }
    })
    
    if(foundBook){
        return true
    }
    else{
        return false
    }
}
