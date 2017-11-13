//
//  ChangePasswordViewController.swift
//  Showcase
//
//  Created by guillermo_lopez6988 on 11/3/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmNewPasswordField: UITextField!
    
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
    
    /* TODO: resets password but does not check old password */
    @IBAction func changePasswordClicked(_ sender: Any) {
        print("*** change password Fields ***")
        print("\tNew Password: "   + newPasswordField.text!)
        print("\tConfirm New PW: " + confirmNewPasswordField.text!)
        print("\n")
        
        // check to see if new password and confirmation password are the same
        if newPasswordField.text != confirmNewPasswordField.text {
            self.showAlert(title: "Error", message: "Password fields did not match.\nTry again.")
            print("old and new passwords do not match")
            return
        }
        
        // get the information of the currenly signed in user
        let curUser = Auth.auth().currentUser
        
        // make sure a user is signed in
        if curUser == nil {
            print("Error: no user signed in")
            return
        }
        
        // check to see if the password entered is correct
       /* var credential: AuthCredential
        
        curUser?.reauthenticate(with: credential) { error in
            if let error = error {
                // An error happened.
                print("user has NOT been reauthenticated")
            } else {
                // User re-authenticated.
                print("user has been reauthenticated");
            }
        }*/
        
        // change current password to new password
 
        curUser?.updatePassword(to: newPasswordField.text!) { (error) in
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch errorCode {
                        case .weakPassword:
                            print ("Weak Password")
                            self.showAlert(title: "Error", message: "Password is too weak. Try 6 or more characters.")
                        default:
                            print("Unknown authentication error: ", errorCode)
                            break
                    }
                }
            }
            else {
                print ("Password succesfully changed.")
                self.performSegueAndShowAlert(title: "Success", message: "Password successfully updated.", segueName: "signUpToRootSegue")
                
            }
        }
 
        // seque to root screen
    }
    
    func performSegueAndShowAlert(title: String, message: String, segueName: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if segueName != nil {
                // self.performSegue(withIdentifier: segueName!, sender: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
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
