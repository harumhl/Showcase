//
//  LoginViewController.swift
//  Showcase
//
//  Created by ellisbrandon20 on 9/20/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailInput.delegate = self
        emailInput.returnKeyType = UIReturnKeyType.done
        
        passwordInput.delegate = self
        passwordInput.returnKeyType = UIReturnKeyType.done
        
        // I set these tags in the XCode textField properties
        //emailInput.tag = 0
        //passwordInput.tag = 1
        
//        emailInput.layer.cornerRadius = 15
//        passwordInput.layer.cornerRadius = 10
        
//        emailInput.layer.borderColor = (UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0) as! CGColor)
//        emailInput.layer.backgroundColor = (UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0) as! CGColor)
//        passwordInput.layer.borderColor = (UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0) as! CGColor)
//        passwordInput.layer.backgroundColor = (UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0) as! CGColor)
        
        
        
        
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
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
        print(":")
        
    }
    
    //presses the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        //return (true)
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
