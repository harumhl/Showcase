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
import SafariServices
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import NVActivityIndicatorView

class PostScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var theBarcodeData: String = ""
    var fromHistory: Bool = false
    var bookData = Book()
    var storeAddress: String = ""
    var storeName: String = "nnnnn"
    var storeAssociateTag: String = ""
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
    @IBOutlet weak var storeLoc: UILabel!
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    @IBAction func PurchaseBook(_ sender: Any) {
        // Set Firebase DB reference
        ref = Database.database().reference()
        self.ref?.child("store").observe(DataEventType.value, with: { (snapshot) in
            // grab the list of all books
            let allStores = snapshot.value as? NSDictionary
            if (allStores == nil) { return }
            
            // Loop through the stores and grab the storeKey value. A store entry is a dictionary ('storeID' -> 'storeKey')
            print("self store address")
            print(self.storeAddress)
            for (_, value) in allStores! {
                let dbStore = value as! NSDictionary
                let dbStoreAddress = dbStore["address"] as! String
                print(dbStoreAddress)
                
                if (dbStoreAddress == self.storeAddress) { // storeAddress is the current store address
                    self.storeAssociateTag = dbStore["associateTag"] as! String
                }
            }
            
            if (self.storeAssociateTag != "") {
                self.bookData.purchaseURL = ""
                self.bookData.purchaseURL = "https://www.amazon.com/gp/product/"
                self.bookData.purchaseURL += self.bookData.ASIN
                self.bookData.purchaseURL += "/ref=as_li_tl?ie=UTF8&tag="
                self.bookData.purchaseURL += self.storeAssociateTag
                self.bookData.purchaseURL += "&camp=1789&creative=9325&linkCode=as2&creativeASIN="
                self.bookData.purchaseURL += self.bookData.ASIN
            }
            
            //storeAddress
            print("Purchase clicked")
            print(self.bookData.purchaseURL)
            let svc = SFSafariViewController(url: URL(string: self.bookData.purchaseURL)!)
            self.present(svc, animated: true, completion: nil)
        })
    }
    
    // Stuff that runs when the VC is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("****** store: \(self.storeName)")
        
        // Do any additional setup after loading the view.
        
        // Getting the setting for Star Rating display
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
        
        // Updating the Display
        self.displayBookInfo()
        activityIndicatorView.startAnimating()
        //ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        //self.title = self.storeName

        
        if !fromHistory {
            addDataToDB()
            fromHistory = false
        }
        
        // for the ReviewTable
        self.reviewsTable.delegate = self
        self.reviewsTable.dataSource = self
        
        self.reviewsTable.estimatedRowHeight = 100.0
        self.reviewsTable.rowHeight = UITableViewAutomaticDimension
        
        
        //self.getReviewsFromReviewURL()

        DispatchQueue.global(qos: .background).async { // Use background threads so book info is displayed while parsing reviews
            self.getReviewsFromReviewURL()
            DispatchQueue.main.async {
                //self.cosmosView.performSelector(onMainThread: #selector(CosmosView.update), with: nil, waitUntilDone: true)
                self.reviewsTable.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: true)
            }
            

        }
//        DispatchQueue.main.async {
//            self.cosmosView.performSelector(onMainThread: #selector(CosmosView.reloadInputViews), with: nil, waitUntilDone: true) // DOESN'T WORK
//            self.reviewsTable.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: true)
//        }
//        print("hide activity")
//        //ViewControllerUtils().hideActivityIndicator(uiView: self.view)
//        print("hide activity 2")
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
        bookAuthor.text = self.storeName//bookData.author
        bookPrice.text = bookData.price
        //storeLoc.text = self.storeName
    }
    
    
    func getReviewsFromReviewURL() {
            let theURL = bookData.reviewURL
            print("Review URL: " + theURL)
            
            // Skip if the book has no reviews
            if (theURL == "Reviews Not Available") {
                print("Reviews Not Available")
            }
        
            print("validating URL....")
            // Check the validity of the URL ("guard" checks it)
            guard let url = URL(string: theURL) else {
                print("Error: cannot create URL")
                return
            }
            print("Done")
        
            print("get HTML String...")
            // Get the HTML source from the URL
            var myHTMLString = ""
            do {
                myHTMLString = try String(contentsOf: url)
                //print("HTML : \(myHTMLString)")
            } catch let error as NSError {
                print("Error: \(error)")
            }
            print("Done ")
            
            // Use Swift Soup to parse the HTML source
            do {
                // Parse the HTML
                print("parsing....")
                let reviewDoc = try SwiftSoup.parse(myHTMLString)
                print("done parsing")
                
                //get the total review for the book by using "arp-rating-out-of-text"
                var ratingStr: String = try reviewDoc.getElementsByClass("arp-rating-out-of-text").text()
                print("RatingStr: ", ratingStr)
                ratingStr = ratingStr.substring(to: ratingStr.index(of: " ")!)
                let ratingUnformatted = Double(ratingStr)
                bookData.rating = Double(String(format: "%.1f", ratingUnformatted!))!
                
                // Display the rating with stars (not the number)
                // https://github.com/evgenyneu/Cosmos
                cosmosView.rating = bookData.rating
                cosmosView.text = String(format:"%.2f", bookData.rating)
                DispatchQueue.main.async {
                    self.cosmosView.performSelector(onMainThread: #selector(CosmosView.update), with: nil, waitUntilDone: true)
                }
                

                
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
                    
                    
                    DispatchQueue.main.async {
                        // refreshes tableView with data
                        self.reviewsTable.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: true)
                    }
                    
                }
                
                DispatchQueue.main.async {
                    // hide the activity indicator once all reviews are loaded
                    let animating = self.activityIndicatorView.animating
                    if(animating){
                        self.self.activityIndicatorView.stopAnimating()
                    }
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
        } else {
             // The user might be logged in with Facebook
        
            let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
            
                req.start({ (response, result) in
                    switch result {
                    case .success(let graphResponse) :
                        if let resultDict = graphResponse.dictionaryValue {
                            email = resultDict["email"] as! String
                            print("FB Email1: ", email)
                            email = email.substring(to: email.index(of: "@")!)
                            print("FB Email2: ", email)
                        }
                    case .failed(_): break
                        
                    }
                })
            
        }

            print("FB Email3: ", email)
            
        
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
            // Embrace nature of syncrhnous programming
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when) {
                print ("Writing to user: ", email)
                let bookRef = self.ref.child("/user/" + email + "/books")
                let thisBookRef = bookRef.childByAutoId()
                thisBookRef.setValue(userBookData)
            }
            /***********************************************/
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
