//
//  SignUpViewController.swift
//  Showcase
//
//  Created by Brian Ta on 9/25/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
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
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func registerUser(_ sender: Any) {
        // Verify password field = confirm password
        print("Sign Up Fields:")
        print("\tFirst Name: " + firstNameField.text!)
        print("\tLast Name: "  + lastNameField.text!)
        print("\tEmail: "      + emailField.text!)
        print("\tPassword: "   + passwordField.text!)
    
        if passwordField.text == confirmPasswordField.text {
            // Create the user
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                // ..
                // segue into main menu
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                        switch errorCode {
                            case .invalidEmail:
                                print ("Invalid Email")
                                self.showAlert(title: "Error", message: "That email sucked, try again.")
                            case .weakPassword:
                                print ("Weak Password")
                                self.showAlert(title: "Error", message: "Password is too weak. Try 6 or more characters.")
                            default:
                                print("Check error: ", errorCode)
                                break
                        }
                    }
                } else {
                    print ("Successful")
                    // self.showAlert(title: "Success", message: "Creating user...")
                    // Need a way to navigate to the main menu (login) or back so that they can log in.
                    // _ = self.navigationController?.popToRootViewController(animated: true)
                    // DispatchQueue.main.async(execute: {
                    // For some reason this disables the Navigation Bar which breaks the app.
                       self.performSegue(withIdentifier: "signUpToRootSegue", sender: nil)
                    // })
                }
            }
        }
        
        // End registerUser
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
