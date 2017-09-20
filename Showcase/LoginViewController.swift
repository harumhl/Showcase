//
//  LoginViewController.swift
//  Showcase
//
//  Created by ellisbrandon20 on 9/20/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func Login(_ sender: Any) {
        
        // validate credentials
        
        // ...
        
        // segue
        
        performSegue(withIdentifier: "loginToRootSegue", sender: nil)

        
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
