//
//  ContributionsTableViewController.swift
//  Showcase
//
//  Created by Brian Ta on 11/20/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import FBSDKCoreKit

class ContributionsTableViewController: UITableViewController {

    let cellReuseIdentifier = "cell"
    var email: String = ""
    var ref:DatabaseReference?
    var bookLocationArray : [Location] = []
    var allBookLocationArray : [Location] = []
    @IBOutlet var contributionsTable: UITableView!
    
    let LAT_THRESHOLD = 5.0
    let LONG_THRESHOLD = 5.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contributionsTable.delegate = self
        contributionsTable.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        // Embrace nature of syncrhnous programming
        self.getStoresFromDB()
        print("Finished doing the stuff")
    
    }

    // Read from the database and grab
    // - Store
    // - Location (Address)
    // - Number of visits
    // - "You contributed xxx amount to this store!"
    func getStoresFromDB() {
        print("**************Authenticating user\n")
        authenticateUser()
        print("**************Getting Stores\n")
        getStores()
    }
    
    func authenticateUser() {
        // Set up user account
        let user = Auth.auth().currentUser
        // email = ""
        if let user = user {
            self.email = user.email!
            self.email = email.substring(to: email.index(of: "@")!)
        } else {
            // The user might be logged in with Facebook
            let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
            req.start({ (response, result) in
                switch result {
                case .success(let graphResponse) :
                    if let resultDict = graphResponse.dictionaryValue {
                        self.email = resultDict["email"] as! String
                        print("FB Email1: ", self.email)
                        self.email = self.email.substring(to: self.email.index(of: "@")!)
                        print("FB Email2: ", self.email)
                    }
                case .failed(_): break
                }
            })
        }
    }
    
    func getStores() {
        // Embrace nature of syncrhnous programming
        self.title = "Contributions for " + self.email
        // Set Firebase DB reference
        self.ref = Database.database().reference()
        print("Loading books for :::::::::::: ", self.email)
        self.ref?.child("user").child(self.email + "/books").observe(DataEventType.value, with: { (snapshot) in
            print("Reading data")
            // Grab the list user's book list (UniqueKey -> bookID)
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
                        let locationID = aUserBook.value(forKey: "LocationID") as! String
                        print ("*********** Location ID is : ", locationID)
                        self.getLocationData(locKey: locationID)
                    }
                }
                let when = DispatchTime.now() + 0.25
                DispatchQueue.main.asyncAfter(deadline: when) {
                    print("Count before reloading data: ", self.bookLocationArray.count)
                    self.contributionsTable.reloadData()
                }
            })
        })
        print("At the end of getting store")
    }
    
    func getLocationData(locKey: String) {
        var location = Location()
        self.ref?.child("location").child("loc" + locKey).observe(DataEventType.value, with: { (snapshot) in
            // Populate the location array
            let theLocation = snapshot.value as! NSDictionary
            location.storeName = theLocation.value(forKey: "StoreName") as! String
            location.latitude = theLocation.value(forKey: "Lat") as! Double
            location.longitude = theLocation.value(forKey: "Long") as! Double
            location.address = theLocation.value(forKey: "Address") as! String
        })
        
        var storeExists = false
        // check to see if the store is already in the location array.
        for loc in self.bookLocationArray {
            if (loc.storeName == location.storeName && loc.address == location.address) {
                print ("got to here")
                // threshold for lat and logitude to decide if two stores are the same
                if (abs(loc.latitude - location.latitude) <= LAT_THRESHOLD &&
                    abs(loc.longitude - location.longitude) <= LONG_THRESHOLD) {
                    // same store
                    print("got to here 2")
                    storeExists = true
                }
            }
        }
        if !storeExists {
            print("The store doesnt exist we add it")
            self.bookLocationArray.append(location)
        }
        
        self.allBookLocationArray.append(location)
        print("boook location array count :: ", self.bookLocationArray.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookLocationArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ContributionsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ContributionsTableViewCell
        
        var location = bookLocationArray[indexPath.row]
        cell.storeName?.text = location.storeName
        cell.storeAddress?.text = location.address
        
        var numVisits = 0
        
        for loc in self.allBookLocationArray {
            if (loc.storeName == location.storeName && loc.address == location.address) {
               
                // threshold for lat and logitude to decide if two stores are the same
                if (abs(loc.latitude - location.latitude) <= LAT_THRESHOLD &&
                    abs(loc.longitude - location.longitude) <= LONG_THRESHOLD) {
                    // same store
                    numVisits += 1
                }
            }
        }
        
        cell.numVisits?.text = "Number of books scanned : "+String(numVisits)
        cell.amtContributed?.text = "$35.99"
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped cell number \(indexPath.row)")
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
