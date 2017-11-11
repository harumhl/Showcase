//
//  HistoryTableViewController.swift
//  Showcase
//
//  Created by ellisbrandon20 on 9/18/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import FBSDKCoreKit

class HistoryTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var userBookArray : [Book] = []
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    @IBOutlet var historyTable: UITableView!
    let cellReuseIdentifier = "cell"
    var selectedBookIndex = -1
    
    var filteredBooks : [Book] = [] // userBookArray contains all history. But this is the array that is displayed (always)
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTable.delegate = self
        historyTable.dataSource = self
        
        // Set Firebase DB reference
        ref = Database.database().reference()
        
        // Set up user account
        let user = Auth.auth().currentUser
        var email = ""
        if let user = user {
            email = user.email!
            email = email.substring(to: email.index(of: "@")!)
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
        
        // Embrace nature of syncrhnous programming
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.title = "Scan history for " + email
            // Get book data from database
            self.ref?.child("user").child(email + "/books").observe(DataEventType.value, with: { (snapshot) in
                // Grab the list user's book list (UniqueKey -> bookID)
                self.userBookArray = [Book]()
                let userBooks = snapshot.value as? NSDictionary
                if (userBooks == nil) { return }
                self.ref?.child("book").observe(DataEventType.value, with: { (snapshot2) in
                    // grab the list of all books
                    let allBooks = snapshot2.value as? NSDictionary
                    if (allBooks == nil) { return }
                    // Loop through the user's books and grab the bookKey value. A user's book entry is a dictionary ('bookID' -> 'bookKey')
                    for (_, value) in userBooks!{
                        // See if we can find the user's book in the main book list.
                        let userBook = value as! NSDictionary
                        let theUserBookKey = userBook["bookID"]
                        // find the users book from the set of all books
                        if allBooks![theUserBookKey as Any] != nil {
                            let aUserBook = allBooks![theUserBookKey!] as! NSDictionary
                            // Grab Book fields from DB
                            self.getBookAttributes(aUserBook: aUserBook)
                        }
                    }
                    // If the seconds since 1970 is a greater value, then it is more recent
                    self.userBookArray.sort { $0.SecondsSince1970 > $1.SecondsSince1970 }
                    
                    // Reload the table view
                    self.filteredBooks = self.userBookArray
                    self.historyTable.reloadData()
                })
            })
        }

        configureSearchController()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // Update the local copy of the user's book array.
    // Make sure to update this function as more attributes are gathered from the Database
    func getBookAttributes(aUserBook: NSDictionary) {
        var tempBook = Book()
        tempBook.ISBN = aUserBook.value(forKey: "BookISBN") as! String
        tempBook.author = aUserBook.value(forKey: "Author") as! String
        tempBook.title = aUserBook.value(forKey: "Title") as! String
        tempBook.imageURL = aUserBook.value(forKey: "ImageURL") as! String
        tempBook.price = aUserBook.value(forKey: "Price") as! String
        tempBook.reviewURL = aUserBook.value(forKey: "ReviewURL") as! String
        tempBook.SecondsSince1970 = UInt(aUserBook.value(forKey: "CreationSecondsSince1970") as! Int)
        tempBook.purchaseURL = aUserBook.value(forKey: "PurchaseURL") as! String
        
        let locationKey = aUserBook.value(forKey: "LocationID") as! String
        self.ref?.child("location").child("loc" + locationKey).observe(DataEventType.value, with: { (snapshot) in
            let theLocation = snapshot.value as! NSDictionary
            // Grab Location StoreName field from DB
            if (theLocation.value(forKey: "StoreName") != nil) {
                tempBook.location.storeName = theLocation.value(forKey: "StoreName") as! String
                tempBook.location.lat = theLocation.value(forKey: "Lat") as! Double
                tempBook.location.long = theLocation.value(forKey: "Long") as! Double
                //tempBook.location.address = theLocation.value(forKey: "Address") as! String
            }
            else {
                tempBook.location.storeName = "Not searched at a store"
                tempBook.location.lat = -1
                tempBook.location.long = -1
                tempBook.location.address = "Address Unavailable"
            }
        })
        loadBookReview(tempBook: tempBook)
        self.userBookArray.append(tempBook)
    }
    
//    func readReviews(_ reviews: inout [Review], bookISBN: String, handleComplete:@escaping (()->())){
//
////          var tmpreviews = [Review]()
//        // Set Firebase DB reference
//        ref = Database.database().reference()
//        self.ref?.child("review").observe(DataEventType.value, with: { (snapshot) in
//            // grab all book reviews
//            let allBooks = snapshot.value as? NSDictionary
//            if(allBooks == nil) { return }
//
//            // loop through and try to find the match for the book currently being searched
//            for (_isbn, _reviews) in allBooks! {
//                let isbn_db = _isbn as! String
//                if(isbn_db == bookISBN){
//                    var tmpReview = Review()
//                    // read the reviews and append to reviews array
//                    for (_key, review) in _reviews as! NSDictionary{
//                        tmpReview.title = (review as! NSDictionary)["reviewTitle"] as! String
//                        tmpReview.date = (review as! NSDictionary)["reviewDate"] as! String
//                        tmpReview.review = (review as! NSDictionary)["reviewText"] as! String
//                        tmpReview.rating = (review as! NSDictionary)["reviewRating"] as! Double
//                    }
////                    tmpreviews.append(tmpReview)
////                    reviews = tmpreviews
//                    reviews.append(tmpReview)
//                }
//            }
//        })
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredBooks.count //return userBookArray.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HistoryTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HistoryTableViewCell
        
        cell.bookTitle?.text = filteredBooks[indexPath.row].title
        cell.author?.text = filteredBooks[indexPath.row].author
        cell.bookPrice?.text = filteredBooks[indexPath.row].price
        if let url = NSURL(string: filteredBooks[indexPath.row].imageURL) {
            if let data = NSData(contentsOf: url as URL) {
                cell.bookImage?.image = UIImage(data: data as Data)
            }
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped cell number \(indexPath.row)")
        selectedBookIndex = indexPath.row
        performSegue(withIdentifier: "HistoryToPost", sender: self)
    }
    
    func configureSearchController() { // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    func updateSearchResults(for searchController: UISearchController) {
        // If we haven't typed anything into the search bar then do not filter the results
        if searchController.searchBar.text! == "" {
            filteredBooks = userBookArray
        } else {
            // Filter the results
            filteredBooks = userBookArray.filter {
                $0.title.lowercased().contains(searchController.searchBar.text!.lowercased()) ||
                $0.author.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
        }
        historyTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let postScanVC: PostScanViewController = segue.destination as! PostScanViewController
        let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
        var bookToPass : Book
        bookToPass = userBookArray[indexPath.row]
        print("Book from History to Post: ", bookToPass)
        postScanVC.bookData = bookToPass
        postScanVC.fromHistory = true
        // find associate tag
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
