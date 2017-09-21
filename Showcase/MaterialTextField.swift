//
//  MaterialTextField.swift
//  Showcase
//
//  Created by Brandon Ellis on 9/21/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

    override func awakeFromNib(){
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor(red:0.79, green:0.79, blue:0.79, alpha:1.0).cgColor
        layer.borderWidth = 1.0
    }

    // For Placeholder Text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    // For Editable Text
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
}
