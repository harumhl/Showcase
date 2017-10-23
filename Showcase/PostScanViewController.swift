//
//  PostScanViewController.swift
//  Showcase
//
//  Created by Brian Ta on 9/18/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase
import Cosmos
import SwiftSoup

class PostScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var theBarcodeData: String = ""
    var fromHistory: Bool = false
    
    var bookData = Book()
    var longitude = 0.0
    var latitude = 0.0
    
    var reviewArray = [Review]()
    
    let cellReuseIdentifier = "cell"
    @IBOutlet weak var reviewsTable: UITableView!
    
    var ref: DatabaseReference!

    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! // book rating in stars
    @IBOutlet weak var bookPrice: UILabel!
    @IBOutlet weak var bookPurchase: UIButton!
    @IBOutlet weak var bookReviews: UITableView!
        
    @IBAction func PurchaseBook(_ sender: Any) {
        performSegue(withIdentifier: "PostToBrowser", sender: self)
    }
    
    // Stuff that runs when the VC is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Getting the setting for Star Rating display
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
//        cosmosView.settings.filledColor = UIColor.yellow
//        cosmosView.settings.emptyBorderColor = UIColor.black
//        cosmosView.settings.filledBorderColor = UIColor.black
        
        // Updating the Display
        self.getReviewsFromReviewURL()
        self.displayBookInfo()
        if !fromHistory {
            addDataToDB()
            fromHistory = false
        }
        
        // for the ReviewTable
        reviewsTable.delegate = self
        reviewsTable.dataSource = self
        
//        reviewsTable.rowHeight = 125.0
        self.reviewsTable.estimatedRowHeight = 100.0
        self.reviewsTable.rowHeight = UITableViewAutomaticDimension
    }
    
    // Built in XCode function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//****************************************** REVIEW TABLE FUNCTIONS ******************************************

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell:ReviewTableViewCell = self.reviewsTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ReviewTableViewCell
        let cell:ReviewTableViewCell = self.reviewsTable.dequeueReusableCell(withIdentifier: "cell") as! ReviewTableViewCell
        
        cell.reviewTitle.text = reviewArray[indexPath.row].title
        
        cell.reviewDate.text = reviewArray[indexPath.row].date
        
        cell.reviewText.text = reviewArray[indexPath.row].review
        
        cell.reviewRating.rating = reviewArray[indexPath.row].rating
        cell.reviewRating.settings.updateOnTouch = false
        
        return cell
    }

//****************************************** USER-DEFINED FUNCTIONS ******************************************
    func displayBookInfo() {
        // Get image from online using the given URL
        if let url = NSURL(string: bookData.imageURL) {
            if let data = NSData(contentsOf: url as URL) {
                self.bookImage.image = UIImage(data: data as Data)
            }
        }
        
        bookTitle.text = bookData.title
        bookAuthor.text = bookData.author
        bookPrice.text = bookData.price
        
        // Display the rating with stars (not the number)
        // https://github.com/evgenyneu/Cosmos
        cosmosView.rating = bookData.rating
        cosmosView.text = String(format:"%.2f", bookData.rating)
    }
    
    
    func getReviewsFromReviewURL() {
        
        
            let theURL = bookData.reviewURL
            print("Review URL: " + theURL)
            
            // Skip if the book has no reviews
            if (theURL == "Reviews Not Available") {
                print("Reviews Not Available")
            }
            
            // Check the validity of the URL ("guard" checks it)
            guard let url = URL(string: theURL) else {
                print("Error: cannot create URL")
                return
            }
            
            // Get the HTML source from the URL
            var myHTMLString = ""
            do {
                myHTMLString = try String(contentsOf: url)
                //print("HTML : \(myHTMLString)")
            } catch let error as NSError {
                print("Error: \(error)")
            }
            
            // Use Swift Soup to parse the HTML source
            do {
                // Parse the HTML
                let reviewDoc = try SwiftSoup.parse(myHTMLString)
                print("review URL: \(theURL)")
                
                //get the total review for the book by using "arp-rating-out-of-text"
                var ratingStr: String = try reviewDoc.getElementsByClass("arp-rating-out-of-text").text()
                print("RatingStr: ", ratingStr)
                ratingStr = ratingStr.substring(to: ratingStr.index(of: " ")!)
                let ratingUnformatted = Double(ratingStr)
                bookData.rating = Double(String(format: "%.1f", ratingUnformatted!))!
                
                
                // "review" gives us the entire review data
                let elems: Elements = try reviewDoc.getElementsByClass("review")
                for review: Element in elems.array(){
                    
                    // "review-title" gives us the <a> tag which has the title text
                    let reviewTitle = try review.getElementsByClass("review-title").text()
                    print("Review Title: " + reviewTitle)
                    
                    // "a-icon-alt" gives you the rating ex: "5.0 out of 5 stars"
                        // then we can check for the first part of that string to assign to a Double variable
                    var reviewRatingStr = try review.getElementsByClass("review-rating").text()
                    //email = email.substring(to: email.index(of: "@")!)
                    reviewRatingStr = reviewRatingStr.substring(to: reviewRatingStr.index(of: " ")!)
                    let reviewRating = Double(reviewRatingStr)
                    print ("Review Rating: \(String(describing: reviewRating))")
                
                    // "review-date"
                    var reviewDate = try review.getElementsByClass("review-date").text()
                    reviewDate = reviewDate.substring(from: reviewDate.index(of: " ")!)
                    print("Review Date: " + reviewDate)
                
                
                    let reviewText = try review.getElementsByClass("review-text").text()
                    print("Review: " + reviewText)
                    print("---------------------------------------------")
                    
                    let tmpReview = Review.init(_title: reviewTitle, _rating: reviewRating!, _date: reviewDate, _review: reviewText)
                    self.reviewArray.append(tmpReview)
                }
            } catch {
                print("error")
            }
    }

//****************************************** Database Functions **********************************************
    func addDataToDB() {
        ref = Database.database().reference()
        let user = getUser()
        var email = ""
        if user.isSignedIn {
            email = user.email.substring(to: user.email.index(of: "@")!)
            print("substring email: ", email)
        }
        
        /*************** WRITTEN TO DB ****************/
        
        let locKey = ref.childByAutoId().key
        let bookKey = ref.childByAutoId().key
        
        let bookData =  ["BookID"    : bookKey,
                         "Title"     : self.bookData.title,
                         "Author"    : self.bookData.author,
                         "BookISBN"  : self.bookData.ISBN,
                         "Price"     : self.bookData.price,
                         "LocationID": locKey,
                         "Purchased" : false,
                         "ImageURL"  : self.bookData.imageURL,
                         "ReviewURL" : self.bookData.reviewURL,
                         "DateCreated" : self.bookData.DateCreatedAt,
                         "CreationSecondsSince1970" : self.bookData.SecondsSince1970,
                         "PurchaseURL": self.bookData.purchaseURL
        ] as [String : Any]
        
        
        let locationData = ["LocationID": locKey,
                            "Long": longitude,
                            "Lat": latitude
        ] as [String : Any]
        
        let userBookData = ["bookID": "bookKey" + bookKey]
        
        // Write a book to the DB
        ref.child("/book/bookKey" + bookKey).setValue(bookData)
        
        // Write a location to the DB
        ref.child("/location/loc" + locKey).setValue(locationData)
        
        // Ensure that no book gets overwritten for a user
        let bookRef = ref.child("/user/" + email + "/books")
        let thisBookRef = bookRef.childByAutoId()
        thisBookRef.setValue(userBookData)
        
        /***********************************************/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let browserVC: BrowserViewController = segue.destination as! BrowserViewController
        browserVC.bookData = self.bookData
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
