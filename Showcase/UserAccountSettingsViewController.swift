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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signOutButton(_ sender: Any) {
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
