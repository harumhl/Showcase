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
        let locKey = ref.childByAutoId().key
        let bookKey = ref.childByAutoId().key

        let bookData = ["BookID": bookKey, "BookISBN": theBarcodeData, "LocationID": locKey, "Purchased": false ] as [String : Any]
        let locationData = ["LocationID": locKey, "Long": longitude, "Lat": latitude] as [String : Any]
        let userData = ["bookID": "bookKey"+bookKey]
        
        ref.child("/book/bookKey"+bookKey).setValue(bookData)
        ref.child("/location/loc"+locKey).setValue(locationData)
        
        let tempBook = Book()
        tempBook.ISBN = theBarcodeData
        user.addBook(b: tempBook)
        print("book size ", user.books.count)
        for book in user.books {
            print ("book " + book.ISBN)
        }
        
        // dont override a users books
        let bookRef = ref.child(byAppendingPath: "/user/"+email+"/books")
        let thisBookRef = bookRef.childByAutoId()
        thisBookRef.setValue(userData)
        
       // print("Data Added:\t" + bookData["BookID"]! + "\t" + bookData["BookISBN"]!)
        //print("LocationID:\t" + locationData["LocationID"] as String! + "\t" + locationData["Long"] as String! + "\t" + locationData["Lat"] as String!)
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
