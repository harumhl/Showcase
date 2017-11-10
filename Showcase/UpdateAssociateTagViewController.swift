//
//  UpdateAssociateTagViewController.swift
//  Showcase
//
//  Created by guillermo_lopez6988 on 11/10/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit

class UpdateAssociateTagViewController: UIViewController {

    @IBOutlet weak var newAmazonTag: UITextField!
    @IBOutlet weak var currentTag: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        currentTag.text = "abc123bca456"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateTag(_ sender: Any) {
        
        // update associate tag in db.
        
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
