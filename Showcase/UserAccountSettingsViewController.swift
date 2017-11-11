//
//  UserAccountSettingsViewController.swift
//  Showcase
//
//  Created by ellisbrandon20 on 9/18/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase

class UserAccountSettingsViewController: UIViewController {
    
    @IBOutlet weak var updateAmazonTagButton: UIButton!
    var ref: DatabaseReference!
    
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        var emailShort = ""
        if let user = user {
            var email = user.email!
            emailShort = email.substring(to: email.index(of: "@")!)
        }
        print("email short is ", emailShort)
        self.ref?.child("user").observe(DataEventType.value, with: { (snapshot) in
            let businessData = snapshot.value as? NSDictionary
            if (!snapshot.hasChild(emailShort)) {
                self.updateAmazonTagButton.isHidden = true
                print("email didnt exist (user hasnot scanned) :: The user is NOT a Business")
                return
            }
            
            self.ref?.child("user").child(emailShort).observe(DataEventType.value, with: { (snapshot) in
                if (!snapshot.hasChild("IsBusiness")) {
                    self.updateAmazonTagButton.isHidden = true
                    print("The user is NOT a Business")
                }
                else {
                    self.updateAmazonTagButton.isHidden = false
                }
            })
        })
        
      
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signOutBtn(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        // Warn the user that they will be signed out.
        let alert = UIAlertController(title: "You will be signed out!", message: "", preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            do {
                try firebaseAuth.signOut()
                self.navigationController?.popToRootViewController(animated: true)
                print("Signed Out!")
            }
            catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func ChangePasswordClicked(_ sender: Any) {
        // once you click on change password
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
