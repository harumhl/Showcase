//
//  LoginViewController.swift
//  Showcase
//
//  Created by ellisbrandon20 on 9/20/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FacebookCore
import FacebookLogin
import FBSDKCoreKit


class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    var handle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailInput.delegate = self
        emailInput.returnKeyType = UIReturnKeyType.next
        
        passwordInput.delegate = self
        passwordInput.returnKeyType = UIReturnKeyType.done
        
        // I set these tags in the XCode textField properties
        //emailInput.tag = 0
        //passwordInput.tag = 1
        
        // border color
        emailInput.layer.borderColor = UIColor.white.cgColor
        passwordInput.layer.borderColor = UIColor.white.cgColor

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide the navigation controller bar
        self.navigationController?.isNavigationBarHidden = true
        emailInput.text = nil
        passwordInput.text = nil
        handle = Auth.auth().addStateDidChangeListener{ (auth, user) in
            //..
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Auth.auth().removeStateDidChangeListener(handle!)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn([ ReadPermission.publicProfile, ReadPermission.email, ReadPermission.userFriends ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(_, _, _):
                print("Logged in!\n")
                self.performSegue(withIdentifier: "loginToRootSegue", sender: nil)
            }
        }
    }

    // Attempt login and validate credentials.
    // If both of these pass then we have an email and a password registered on Firebase
    @IBAction func Login(_ sender: Any) {
        let email = emailInput.text;
        let pwd = passwordInput.text;
        print("Attempting to log in...")
        print("\tEmail: " + email!)
        print("\tPW: " + pwd!)
        Auth.auth().signIn(withEmail: email!, password: pwd!) { (user, error) in
            // Take user to main menu if login has succeeded
            if let user = user {
                print("Login succeeded!")
                print("\tUserID: " + user.uid)
                print("\tEmail: " + user.email!)
                self.performSegue(withIdentifier: "loginToRootSegue", sender: nil)
            }
            else {
                print("Invalid credentials but logging in anyway.")
                // self.showAlert(title: "Authentication Error", message: "Invalid credentials but logging in anyway.");
                // Log in anyway for debugging purposes
                self.performSegue(withIdentifier: "loginToRootSegue", sender: nil)
            }
        }
        
    }
    
    // Button action to take user to signup form
    @IBAction func signUp(_ sender: Any) {
        self.performSegue(withIdentifier: "LoginToSignUp", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "LoginToSignUp"){
             if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 0
            }
        }
    }

    
    // presses the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
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
