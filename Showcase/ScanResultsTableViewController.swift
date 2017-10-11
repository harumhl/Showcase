//
//  ScanResultsTableViewController.swift
//  Showcase
//
//  Created by ellisbrandon20 on 10/9/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit

class ScanResultsTableViewController: UITableViewController {

    var scanBookArray = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
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
        print ("numRows Book Count: \(scanBookArray.count)")
        return scanBookArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print ("Book Count: \(scanBookArray.count)")
        print ("Book title:" + scanBookArray[indexPath.row].title)
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ScanResultsTableViewCell
        
        
        
        
        //cell.bookImage
        
        //        if let url = NSURL(string: "https://images-na.ssl-images-amazon.com/images/I/51wJ%2BUKIhJL._SL160_.jpg") {
        //            if let data = NSData(contentsOf: url as URL) {
        //                //self.bookImage.image = UIImage(data: data as Data)
        //                cell.bookImage = UIImage(data: data as Data) as! UIView
        //            }
        //        }
        
        cell.bookTitle?.text = scanBookArray[indexPath.row].title
        
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
