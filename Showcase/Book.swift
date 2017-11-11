//
//  Book.swift
//  Showcase
//
//  Created by Brandon Ellis on 10/3/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import Foundation
import SwiftSoup

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
    var purchaseURL: String
    var ASIN: String
    var location: Location
    var reviews = [Review]()
    var doneParse = false
    var reviewExist = false
    
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
        purchaseURL = "N/A"
        ASIN = "N/A"
        location = Location()
        //reviews = "N/A"
    }
    
    init(_title: String, _author:String, _ISBN: String, _price: String, _imageURL: String, _rating: Double, _reviewURL: String, _DateCreatedAt: String, _SecondsSince1970: UInt, _purchaseURL: String, _ASIN: String, _location: Location){
        self.title = _title
        self.author = _author
        self.ISBN = _ISBN
        self.price = _price
        self.imageURL = _imageURL
        self.rating = _rating
        self.reviewURL = _reviewURL
        self.DateCreatedAt = _DateCreatedAt
        self.SecondsSince1970 = UInt(_SecondsSince1970)
        self.purchaseURL = _purchaseURL
        self.ASIN = _ASIN
        self.location = _location
    }
    
    func parse(_url: String){
        // Define identifier
        let notifRefreshRating = Notification.Name("refreshRating")
        let notifRefreshTable = Notification.Name("refreshTable")
        let notifRefreshDone = Notification.Name("refreshDone")
        
        let theURL = _url
        //print("BP-Review URL: " + theURL)
        
        // Skip if the book has no reviews
        if (theURL == "Reviews Not Available") {
            print("Reviews Not Available")
        }
        
        //print("BP-validating URL....")
        // Check the validity of the URL ("guard" checks it)
        guard let url = URL(string: theURL) else {
            print("Error: cannot create URL")
            return
        }
        //print("Done")
        
        //print("BP-get HTML String...")
        // Get the HTML source from the URL
        var myHTMLString = ""
        do {
            myHTMLString = try String(contentsOf: url)
            //print("HTML : \(myHTMLString)")
        } catch let error as NSError {
            print("Error: \(error)")
        }
        //print("Done ")
        
        // Use Swift Soup to parse the HTML source
        do {
            // Parse the HTML
            //print("BP-parsing....")
            let reviewDoc = try SwiftSoup.parse(myHTMLString)
            //print("BP-done parsing")
            
            // Get the total review for the book by using "arp-rating-out-of-text"
            var ratingStr: String = try reviewDoc.getElementsByClass("arp-rating-out-of-text").text()
            //print("BP-RatingStr: ", ratingStr)
            ratingStr = ratingStr.substring(to: ratingStr.index(of: " ")!)
            let ratingUnformatted = Double(ratingStr)
            self.rating = Double(String(format: "%.1f", ratingUnformatted!))!
            
            NotificationCenter.default.post(name: notifRefreshRating, object: nil)
            
//            // Display the rating with stars (not the number)
//            // https://github.com/evgenyneu/Cosmos
//            DispatchQueue.main.async {
//                self.cosmosView.rating = self.bookData.rating
//                self.cosmosView.text = String(format:"%.2f", self.bookData.rating)
//                self.cosmosView.performSelector(onMainThread: #selector(CosmosView.update), with: nil, waitUntilDone: true)
//            }
            
            
            // "review" gives us the entire review data
            let elems: Elements = try reviewDoc.getElementsByClass("review")
            for review: Element in elems.array(){
                
                // "review-title" gives us the <a> tag which has the title text
                let reviewTitle = try review.getElementsByClass("review-title").text()
                //print("BP-Review Title: " + reviewTitle)
                
                // "a-icon-alt" gives you the rating ex: "5.0 out of 5 stars"
                // then we can check for the first part of that string to assign to a Double variable
                var reviewRatingStr = try review.getElementsByClass("review-rating").text()
                //email = email.substring(to: email.index(of: "@")!)
                reviewRatingStr = reviewRatingStr.substring(to: reviewRatingStr.index(of: " ")!)
                let reviewRating = Double(reviewRatingStr)
                //print ("BP-Review Rating: \(String(describing: reviewRating))")
                
                // "review-date"
                var reviewDate = try review.getElementsByClass("review-date").text()
                reviewDate = reviewDate.substring(from: reviewDate.index(of: " ")!)
                //print("BP-Review Date: " + reviewDate)
                
                
                let reviewText = try review.getElementsByClass("review-text").text()
                //print("BP-Review: " + reviewText)
                //print("BP----------------------------------------------")
                
                let tmpReview = Review.init(_title: reviewTitle, _rating: reviewRating!, _date: reviewDate, _review: reviewText)
                self.reviews.append(tmpReview)
                NotificationCenter.default.post(name: notifRefreshTable, object: nil)
            }
            
            // Post notification
            NotificationCenter.default.post(name: notifRefreshDone, object: nil)
            self.doneParse = true

            
        } catch {
            print("error")
        }
    }
}
