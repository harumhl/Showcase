//
//  HistoryTableViewController.swift
//  Showcase
//
//  Created by ellisbrandon20 on 9/18/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase

class HistoryTableViewController: UITableViewController {

    var userBookArray = [Book]()
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    @IBOutlet var historyTable: UITableView!
    
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
        }
        

        
        // Get data
        ref?.child("user").child(email + "/books").observe(DataEventType.value, with: { (snapshot) in
            // Grab the list user's book list (UniqueKey -> bookID)
            self.userBookArray = [Book]()
            let userBooks = snapshot.value as? NSDictionary
            if (userBooks == nil) { return }
            self.ref?.child("book").observe(DataEventType.value, with: { (snapshot2) in
                // grab the list of all books
                let allBooks = snapshot2.value as? NSDictionary
                if (allBooks == nil) { return }
                
                // Loop through the user's books and grab the bookKey value
                // A user's book entry is a dictionary ('bookID' -> 'bookKey')
                for (_, value) in userBooks!{
                    // See if we can find the user's book in the main book list.
                    let userBook = value as! NSDictionary
                    let theUserBookKey = userBook["bookID"]
                    // find the users book from the set of all books
                    if allBooks![theUserBookKey as Any] != nil {
                        let tempBook = Book()
                        let aUserBook = allBooks![theUserBookKey!] as! NSDictionary
                        tempBook.ISBN = aUserBook.value(forKey: "BookISBN") as! String
                        self.userBookArray.append(tempBook)
                        // reload the table view
                        self.historyTable.reloadData()
                    }
                }
            })
        })
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //let u = getUser().books
        
        
        
    
        
        
       // print("on load, number of rows in table is = ", curUser.count)
        
    }
    
    func test(bookArray: [Book]?)->() {
        print("hello")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userBookArray.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = userBookArray[indexPath.row].ISBN
        // let label = UILabel(frame: CGRect(x:0, y:0, width:200, height:50))
        // label.text = "text"
        // cell.addSubview(label)
        // Configure the cell...

        return cell
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
