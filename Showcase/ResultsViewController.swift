//
//  ResultsViewController.swift
//  Showcase
//
//  Created by ellisbrandon20 on 10/11/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var scanBookArray = [Book]()
    var selectedBookIndex = -1
    
    var storeAddress: String = ""
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Scan Results"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 176.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanBookArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ResultsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResultsTableViewCell
        
        //cell.bookImage.backgroundColor = self.colors[indexPath.row]
        //cell.bookTitle.text = self.animals[indexPath.row]
        
        cell.bookTitle.text = scanBookArray[indexPath.row].title
        
        cell.bookAuthor.text = scanBookArray[indexPath.row].author
        
        
        if let url = NSURL(string: scanBookArray[indexPath.row].imageURL) {
            if let data = NSData(contentsOf: url as URL) {
                //self.bookImage.image = UIImage(data: data as Data)
                cell.bookImage.image = UIImage(data: data as Data)
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped cell number \(indexPath.row)")
        selectedBookIndex = indexPath.row
        
        //performSegue(withIdentifier: "ResultsToPost", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let postScanVC: PostScanViewController = segue.destination as! PostScanViewController
        //var indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()!
        let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
        var bookToPass : Book
        bookToPass = scanBookArray[indexPath.row]
        postScanVC.bookData = bookToPass
        postScanVC.storeAddress = self.storeAddress
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
