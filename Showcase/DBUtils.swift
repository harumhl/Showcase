//
//  DBUtils.swift
//  Showcase
//
//  Created by ellisbrandon20 on 11/10/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import Foundation
import Firebase


func loadBookReview(tempBook: Book, handleComplete:@escaping (()->())){
    print("in loadBookReview()")
    // Set Firebase DB reference
    var ref = Database.database().reference()
    ref.child("review").observe(DataEventType.value, with: { (snapshot) in
        // grab all book reviews
        let allBooks = snapshot.value as? NSDictionary
        if(allBooks == nil) { return }
        
        // loop through and try to find the match for the book currently being searched
        for (_isbn, _reviewData) in allBooks! {
            let isbn_db = _isbn as! String
            if(isbn_db == tempBook.ISBN){
                
                // get rating
                tempBook.rating = (_reviewData as! NSDictionary).value(forKey: "rating") as! Double
                var _reviews = [String : Any]()
                
                if((_reviewData as! NSDictionary).value(forKey: "reviews") == nil) {
                    continue
                }
                else {
                    _reviews = (_reviewData as! NSDictionary).value(forKey: "reviews") as! [String : Any]
                }
                
                // read the reviews and append to reviews array
                for (_key, review) in _reviews as! NSDictionary{
                    var tmpReview = Review()
                    tmpReview.title = (review as! NSDictionary)["reviewTitle"] as! String
                    tmpReview.date = (review as! NSDictionary)["reviewDate"] as! String
                    tmpReview.review = (review as! NSDictionary)["reviewText"] as! String
                    tmpReview.rating = (review as! NSDictionary)["reviewRating"] as! Double
                    tempBook.reviews.append(tmpReview)
//                    let notifRefreshRating = Notification.Name("refreshRating")
//                    NotificationCenter.default.post(name: notifRefreshRating, object: nil)
                }
                
                print("check tempBook")
                
//                let notifRefreshDone = Notification.Name("refreshDone")
//                NotificationCenter.default.post(name: notifRefreshDone, object: nil)
                print("refreshDone")
                handleComplete()
                return
            }
        }
    })
    
}


func loadBookReview(bookarray: [Book], handleComplete:@escaping (()->())){
   
    print("in loadBookReview()")
    // Set Firebase DB reference
    var ref = Database.database().reference()
    ref.child("review").observe(DataEventType.value, with: { (snapshot) in
        for tempBook in bookarray {
            // grab all book reviews
            let allBooks = snapshot.value as? NSDictionary
            if(allBooks == nil) { return }
            
            // loop through and try to find the match for the book currently being searched
            for (_isbn, _reviewData) in allBooks! {
                let isbn_db = _isbn as! String
                if(isbn_db == tempBook.ISBN){
                    
                    // get rating
                    tempBook.rating = (_reviewData as! NSDictionary).value(forKey: "rating") as! Double
                    var _reviews: [String : Any]
                    do {
                        try _reviews = (_reviewData as! NSDictionary).value(forKey: "reviews") as! [String : Any]
                    }
                    catch {
                        // No reviews found. Continue with the next book
                        continue
                    }
                    
                    
                    // read the reviews and append to reviews array
                    for (_key, review) in _reviews as! NSDictionary{
                        var tmpReview = Review()
                        tmpReview.title = (review as! NSDictionary)["reviewTitle"] as! String
                        tmpReview.date = (review as! NSDictionary)["reviewDate"] as! String
                        tmpReview.review = (review as! NSDictionary)["reviewText"] as! String
                        tmpReview.rating = (review as! NSDictionary)["reviewRating"] as! Double
                        tempBook.reviews.append(tmpReview)
//                        let notifRefreshRating = Notification.Name("refreshHistRating")
//                        NotificationCenter.default.post(name: notifRefreshRating, object: nil)
                        
                    }
                    let notifRefreshTable = Notification.Name("refreshHistTable")
                    NotificationCenter.default.post(name: notifRefreshTable, object: nil)
                    print("check tempBook")
                    
                    
                    print("refreshDone")
                    return
                }
            }
        }
        let notifRefreshDone = Notification.Name("refreshHistDone")
        NotificationCenter.default.post(name: notifRefreshDone, object: nil)
        handleComplete()
    })
}

func isReviewInDB(bookData: Book, handleComplete:@escaping (()->())) {
    print("in isReviewInDB()")
    // using the bookData.reviewURL check if the review object already exists in the database
    // Set Firebase DB reference
    var ref = Database.database().reference()
    ref.child("review").observe(DataEventType.value, with: { (snapshot) in
        // grab all book reviews
        let allBooks = snapshot.value as? NSDictionary
        if(allBooks == nil) { return }
        
        // loop through and try to find the match for the book currently being searched
        for (isbn, _) in allBooks! {
            let isbn_db = isbn as! String
            //print("isbn_db: \(isbn)")
            if(isbn_db == bookData.ISBN){
                print("found ISBN in ReviewDB no need to write to DB")
                bookData.reviewExist = true
                handleComplete()
                return
            }
        }
        //bookData.reviewExist = false
        print("didn't find ISBN in ReviewDB")
        handleComplete()
        return
    })
}

// Try to find a way to use the function below?? maybe this is how we need to control running the full function before returning see: https://stackoverflow.com/questions/41262793/swift-wait-for-firebase-to-load-before-return-a-function 

//func isReview(bookData: Book, completionHandler:@escaping (_ flag: Bool)->()) {
//
//    // using the bookData.reviewURL check if the review object already exists in the database
//    var flag = false
//    // Set Firebase DB reference
//    var ref = Database.database().reference()
//    ref.child("review").observe(DataEventType.value, with: { (snapshot) in
//        // grab all book reviews
//        let allBooks = snapshot.value as? NSDictionary
//        if(allBooks == nil) { return }
//
//        // loop through and try to find the match for the book currently being searched
//        for (isbn, _) in allBooks! {
//            let isbn_db = isbn as! String
//            //print("isbn_db: \(isbn)")
//            if(isbn_db == bookData.ISBN){
//                print("found ISBN in ReviewDB no need to write to DB")
//                bookData.reviewExist = true
//                flag = true
//                completionHandler(flag)
//            }
//        }
//        completionHandler(flag)
//    })
//}

func findStoreAssociateTag(address: String, location: Location, handleComplete:@escaping (()->())) {
    var ref: DatabaseReference!
    
    // Set Firebase DB reference
    ref = Database.database().reference()
    ref?.child("store").observe(DataEventType.value, with: { (snapshot) in
        // grab the list of all books
        let allStores = snapshot.value as? NSDictionary
        if (allStores == nil) { return }
        
        // Loop through the stores and grab the storeKey value. A store entry is a dictionary ('storeID' -> 'storeKey')
        print("self store address")
        print(address)
        
        for (_, value) in allStores! {
            let dbStore = value as! NSDictionary
            print(dbStore["address"] as! String)
            
            if (dbStore["address"] as! String == address) { // storeAddress is the current store address
                print ("found123")
                location.associateTag = dbStore["associateTag"] as! String
                //print (dbStore["associateTag"])
                handleComplete()
                break
            }
        }
    })
}
