//
//  ChangeEmailViewController.swift
//  Showcase
//
//  Created by Brian Ta on 11/13/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase

class ChangeEmailViewController: UIViewController {


    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var confirmEmailField: UITextField!
    @IBOutlet weak var changeEmailButton: UIButton!
    var ref:DatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // Show a popup alert.
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeEmailButtonClicked(_ sender: Any) {
        // Add functionality to change the user's email from the given input
        if (newEmailField.text != confirmEmailField.text) {
            // Alert that the email fields do not match
        }
        else {
            // Set Firebase DB reference
            ref = Database.database().reference()
            
            // Grab user's current email
            let curUser = Auth.auth().currentUser
            var curEmail = ""
            if let user = curUser {
                curEmail = user.email!
            }
            
            // Run the email change on Firebase
            Auth.auth().currentUser?.updateEmail(to: confirmEmailField.text!) { (error) in
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                        switch errorCode {
                            case .invalidEmail:
                                print ("Invalid Email")
                                self.showAlert(title: "Error", message: "That email sucked, try again.")
                            // Type "case ." to see all of the different error codes.
                            default:
                                print("Unknown authentication error: ", errorCode)
                                break
                        }
                    }
                }
            }
            
            // Change the user email on the table
//            curEmail = curEmail.substring(to: curEmail.index(of: "@")!)
//            let newEmail = confirmEmailField.text?.substring(to: (confirmEmailField.text?.index(of: "@")!)!)
//            print ("Changing user's current email: " + curEmail + " to the new email: " + newEmail!)
//            ref?.child("user").updateChildValues([curEmail: newEmail])
        }
        
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
