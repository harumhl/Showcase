//
//  BusinessSignUpViewController.swift
//  Showcase
//
//  Created by froob on 11/8/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class BusinessSignUpViewController: UIViewController {

    @IBOutlet weak var businessName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var amazonAscTag: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
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
    
    
    @IBAction func businessRegister(_ sender: Any) {
        print("*** Sign Up Fields ***")
        print("\nBusnessName: "      + businessName.text!)
        print("\tEmail: "   + email.text!)
        print("\tAmazon Asc Tag: " + amazonAscTag.text!)
        print("\tPW: " + passwordField.text!)
        print("\tConfirm PW: " + confirmPasswordField.text!)
        print("\n")
        // Check for password confirmation
        if passwordField.text == confirmPasswordField.text {
            // Create the user
            Auth.auth().createUser(withEmail: email.text!, password: passwordField.text!) { (user, error) in
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                        switch errorCode {
                        case .invalidEmail:
                            print ("Invalid Email")
                            self.showAlert(title: "Error", message: "That email sucked, try again.")
                        case .weakPassword:
                            print ("Weak Password")
                            self.showAlert(title: "Error", message: "Password is too weak. Try 6 or more characters.")
                        // Type "case ." to see all of the different error codes.
                        default:
                            print("Unknown authentication error: ", errorCode)
                            break
                        }
                    }
                }
                    // There were no errors from authentication
                else {
                    print ("User creation successful.")
                    self.performSegueAndShowAlert(title: "Success", message: "Business creation successful.", segueName: "businessSignUpToRootSegue")
                }
            }
        }
        else {
            self.showAlert(title: "Error", message: "Password fields did not match.")
        }
        
        // End registerUser button function
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
