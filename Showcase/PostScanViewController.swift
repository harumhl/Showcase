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
