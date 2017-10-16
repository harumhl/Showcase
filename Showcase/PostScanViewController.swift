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



class PostScanViewController: UIViewController{
    var theBarcodeData: String = ""
    
    var bookData = Book()
    var longitude = 0.0
    var latitude = 0.0

    var ref: DatabaseReference!

    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! // book rating in stars
    @IBOutlet weak var bookPrice: UILabel!
    @IBOutlet weak var bookPurchase: UIButton!
    @IBOutlet weak var bookReviews: UITableView!
        
    // Stuff that runs when the VC is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Print the barcode on a label on the top of the VC
        
        print(bookData.title)
        
        // Getting the setting for Star Rating display
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
        cosmosView.settings.filledColor = UIColor.yellow
        cosmosView.settings.emptyBorderColor = UIColor.black
        cosmosView.settings.filledBorderColor = UIColor.black
        
        // Updating the Display
        getReviewsFromReviewURL()
        displayBookInfo()
        
        addDataToDB()
    }
    
    // Built in XCode function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                let doc = try SwiftSoup.parse(myHTMLString)
                
                // get the All Reviews Link
                let reviewElem: Elements = try doc.getElementsByClass("asinReviewsSummary")
                let reviewTag: Elements = try reviewElem.select("a")
                let reviewLink: String = try! reviewTag.attr("href")
                print("reviewLink: " + reviewLink)
                
                
                // get the HTML code from the All Reviews URL
                guard let reviewURL = URL(string: reviewLink) else {
                    print("Error: cannot create URL")
                    return
                }
                var reviewURlHTMLString = ""
                do {
                    reviewURlHTMLString = try String(contentsOf: reviewURL)
                } catch let error as NSError {
                    print("Error: \(error)")
                }
                
                // Parse the HTML
                let reviewDoc = try SwiftSoup.parse(reviewURlHTMLString)
                
                
                // "a-section review" gives us the entire review data
                
                // $(".review .a-link-normal").title; gives you the rating ex: "5.0 out of 5 stars"
                    // then we can check for the first part of that string to assign to a Double variable
                
                
                // get the array of "review-text" elements
                let elems: Elements = try reviewDoc.getElementsByClass("review-text")
                for review: Element in elems.array(){
                    let reviewText = try review.text()
                    print("Review: " + reviewText)
                }
                
                
                

//                let link: Elements = try doc.select("a[href]")
//                let linkHref: String = try! link.attr("href");
                
//                let elems: Elements = try doc.select("reviewText")
//                for review: Element in elems.array(){
//                    let reviewStr: String =  try review.text()
//                    print("reviewSTR: " + reviewStr)
//                }
                
                
                
                
                
//                let docBody = doc.body()
//                //print("Doc Body: ")
//                //print(docBody)
//                //print("\n\n")
//
//                let elem = try doc.getElementsByClass("crIframeReviewList").get(0)
//                let table = try elem.getElementsByTag("table").get(0)
//                let tbody = try table.getElementsByTag("tbody").get(0)
//                let tr = try tbody.getElementsByTag("tr").get(0)
//                let td = try tr.getElementsByTag("td").get(0)
//                let divs = try td.getElementsByTag("div")
//
//                print("Doc elem: ")
//                for div in divs { // each review
//                    //print("hmm?????")
//                    //print(div)
//                    //print(try div.text())
//
//                    if (try div.getElementsByTag("b").array().count > 0) {
//                        print(try div.getElementsByTag("b").get(0))
//                    }
//
//                    if (try div.getElementsByTag("div").array().count > 0) {
//                        let div_ = try div.getElementsByTag("div").get(0)
//                        let div__ = try div_.getElementsByTag("div")
//                        //print(div_)
//
//                        if (div__.array().count > 1) {
//                            let div1 = div__.get(1)
//                            let div1b = try div1.getElementsByTag("b")
//                            if (div1b.array().count > 0) {
//                                let title = try div1b.array()[0].text() // NOT ALWAYS!!!!
//                                print("Title:: " + title)
//                            }
//                        }
//                    }
//                }
                /*
                 //print(try divs.array()[0].text() + "\n\n\n")
                 let aaa = try divs.get(0).getElementsByTag("div").get(0)
                 let bbb = try aaa.getElementsByTag("div").array()[0]
                 let ccc = try bbb.getElementsByTag("div")
                 print(bbb)
                 let title = try ccc.get(1).getElementsByTag("b")
                 print(try title.text())
                 //let author = try aaa.get(2).getElementsbyTag("div").get
                 */
                
            } catch {
                print("error")
            }
            
//            // Start URL session
//            let urlRequest = URLRequest(url: url)
//            let session = URLSession.shared
//
//            // Unpack the returned XML data
//            let task = session.dataTask(with: urlRequest) {
//                (data, response, error) in
//                // check for any errors
//                guard error == nil else {
//                    print("error calling GET on /todos/1")
//                    print(error!)
//                    return
//                }
//                // make sure we got data
//                guard let responseData = data else {
//                    print("Error: did not receive data")
//                    return
//                }
//            }
//            task.resume()
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
                         "title"     : self.bookData.title,
                         "author"    : self.bookData.author,
                         "BookISBN"  : self.bookData.ISBN,
                         "Price"     : self.bookData.price,
                         "LocationID": locKey,
                         "Purchased" : false,
                         "ImageURL"  : self.bookData.imageURL,
                         "ReviewURL" : self.bookData.reviewURL
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
    

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
