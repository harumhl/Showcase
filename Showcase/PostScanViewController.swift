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
    var whichVC_itComesFrom: String = "" // whether LoadScanVC or ResultsVC - for "back" button
    
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
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var storePlacemarkImg: UIImageView!
    @IBOutlet weak var storeNameLbl: UILabel!
    
    @IBAction func PurchaseBook(_ sender: Any) {
        print("Purchase clicked!!")
        
        var theURL = self.bookData.purchaseURL
        
        if (storeAssociateTag != "") {
            theURL = "https://www.amazon.com/gp/product/"
            theURL += self.bookData.ASIN
            theURL += "/ref=as_li_tl?ie=UTF8&tag="
            theURL += self.storeAssociateTag
            theURL += "&camp=1789&creative=9325&linkCode=as2&creativeASIN="
            theURL += self.bookData.ASIN
        }
        
        print(theURL)
        let svc = SFSafariViewController(url: URL(string: theURL)!)
        self.present(svc, animated: true, completion: nil)
    }
    
    // Stuff that runs when the VC is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Update the table with review data
        // Define identifier
        let notifRefreshRating = Notification.Name("refreshRating")
        let notifRefreshTable = Notification.Name("refreshTable")
        let notifRefreshDone = Notification.Name("refreshDone")
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(PostScanViewController.refreshRating), name: notifRefreshRating, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostScanViewController.refreshTable), name: notifRefreshTable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostScanViewController.refreshDone), name: notifRefreshDone, object: nil)
        
        print("****** store: \(self.storeName)")
        
        // Custom "back" button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PostScanViewController.backToRoot(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        // Grey out the Purchase button and disable it
        if (storeAssociateTag == "") {
            bookPurchase.backgroundColor = UIColor.gray
            bookPurchase.isEnabled = false
            storePlacemarkImg.image = UIImage(named: "redPlacemark")
            storeNameLbl.text = "This store does not participate with Showcase"
        } else {
            
            if !fromHistory {
                storeNameLbl.text = self.storeName
            }else {
                storeNameLbl.text = self.bookData.location.storeName
            }
        }

        // Getting the setting for Star Rating display
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
        
        // Updating the Display
        self.displayBookInfo()
        
        // if reviews already loaded dont start animation
        if(bookData.rating != -1){
            refreshRating()
        }
        if(!bookData.doneParse){
            activityIndicatorView.startAnimating()
        }
        
        // Display the view controller's title
        if !fromHistory {
            //self.title = "Store: " + self.storeName
            addDataToDB()
            fromHistory = false
        } else {
            // Maybe our Location object will have this information.
            //self.title = self.bookData.location.storeName
        }
        
        // for the ReviewTable
        self.reviewsTable.delegate = self
        self.reviewsTable.dataSource = self
        self.reviewsTable.estimatedRowHeight = 100.0
        self.reviewsTable.rowHeight = UITableViewAutomaticDimension
        
        // Update reviews
//        DispatchQueue.global(qos: .background).async { // Use background threads so book info is displayed while parsing reviews
//            self.getReviewsFromReviewURL()
//        }
        
        

    }
    
    // Built in XCode function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // TODO: broken when logging in as business and scanning a book.
    func backToRoot(sender: UIBarButtonItem) {
        if (whichVC_itComesFrom == "LoadScanVC") {
            // Go back to the root ViewController
            let rootVC: RootViewController = (self.navigationController?.viewControllers[1])! as! RootViewController
            navigationController?.popToViewController(rootVC, animated: true)
        }
        else if (whichVC_itComesFrom == "ResultsVC" || fromHistory == true) {
            // Go back to the ResultsViewController - just go back
            navigationController?.popViewController(animated: true)
        }
        else if (whichVC_itComesFrom == "SignUpVC") {
            // Go back to the ResultsViewController - just go back
            let rootVC: RootViewController = (self.navigationController?.viewControllers[2])! as! RootViewController
            navigationController?.popToViewController(rootVC, animated: true)
        }
    }

    
//****************************************** REVIEW TABLE FUNCTIONS ******************************************
    func refreshRating(){
        DispatchQueue.main.async {
            self.cosmosView.rating = self.bookData.rating
            self.cosmosView.text = String(format:"%.2f", self.bookData.rating)
            self.cosmosView.performSelector(onMainThread: #selector(CosmosView.update), with: nil, waitUntilDone: true)
            print("-- rating: \(self.bookData.rating)")
        }
    }
    
    func refreshTable(){
        DispatchQueue.main.async {
            self.reviewsTable.reloadData()
        }
    }
    
    func refreshDone(){
        DispatchQueue.main.async {
            self.reviewsTable.reloadData()
            let animating = self.activityIndicatorView.animating
            if(animating){
                self.self.activityIndicatorView.stopAnimating()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookData.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:ReviewTableViewCell = self.reviewsTable.dequeueReusableCell(withIdentifier: "cell") as! ReviewTableViewCell
        
        cell.reviewTitle.text = bookData.reviews[indexPath.row].title
        cell.reviewDate.text = bookData.reviews[indexPath.row].date
        cell.reviewText.text = bookData.reviews[indexPath.row].review
        cell.reviewRating.rating = bookData.reviews[indexPath.row].rating
        
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
            
            // Get the total review for the book by using "arp-rating-out-of-text"
            var ratingStr: String = try reviewDoc.getElementsByClass("arp-rating-out-of-text").text()
            print("RatingStr: ", ratingStr)
            ratingStr = ratingStr.substring(to: ratingStr.index(of: " ")!)
            let ratingUnformatted = Double(ratingStr)
            bookData.rating = Double(String(format: "%.1f", ratingUnformatted!))!
            
            // Display the rating with stars (not the number)
            // https://github.com/evgenyneu/Cosmos
            DispatchQueue.main.async {
                self.cosmosView.rating = self.bookData.rating
                self.cosmosView.text = String(format:"%.2f", self.bookData.rating)
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
            
            // hide the activity indicator once all reviews are loaded
            DispatchQueue.main.async {
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
            
        
            /*************** WRITTEN TO DB ****************/
            
            let locKey = ref.childByAutoId().key
            let bookKey = ref.childByAutoId().key
        
            print("Location Object in current book: ", self.bookData.location)
        
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
                                "Long": self.bookData.location.long,
                                "Lat": self.bookData.location.lat,
                                "StoreName": self.bookData.location.storeName
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
