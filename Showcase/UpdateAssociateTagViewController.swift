//
//  UpdateAssociateTagViewController.swift
//  Showcase
//
//  Created by guillermo_lopez6988 on 11/10/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase
import SafariServices


class UpdateAssociateTagViewController: UIViewController {

    @IBOutlet weak var newAmazonTag: UITextField!
    @IBOutlet weak var currentTag: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var checkAmazonInfo: UIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getCurrentTag()
    }
    
    func getCurrentTag() {
        
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        var emailShort = ""
        if let user = user {
            var email = user.email!
            emailShort = email.substring(to: email.index(of: "@")!)
        }
        
        self.ref?.child("user").child(emailShort).observe(DataEventType.value, with: { (snapshot) in
            let businessData = snapshot.value as? NSDictionary
            self.currentTag.text = businessData!.value(forKey: "AssociateTag") as! String
            if (self.currentTag.text == "") {
                self.currentTag.text = "Tag not set"
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func updateButtonClicked(_ sender: Any) {
        
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        var emailShort = ""
        if let user = user {
            var email = user.email!
            emailShort = email.substring(to: email.index(of: "@")!)
        }

 
        ref.child("/user/" + emailShort).child("AssociateTag").setValue(newAmazonTag.text)
        currentTag.text = newAmazonTag.text
        
        print ("User creation successful.")
        self.performSegueAndShowAlert(title: "Success", message: "Amazon Tag sucessfully updated.", segueName: "updateTagToRootSegue")
    }
    
    // Show a popup alert.
    // aSegue is an optional parameter, you can supply one if you want to perform
    // a segue and then show an alert.
    func performSegueAndShowAlert(title: String, message: String, segueName: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if segueName != nil {
                self.performSegue(withIdentifier: segueName!, sender: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func checkAmazonInfoButtonClicked(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string: "https://affiliate-program.amazon.com/")!)
        self.present(svc, animated: true, completion: nil)
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
