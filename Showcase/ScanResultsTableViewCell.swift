//
//  ScanResultsTableViewCell.swift
//  Showcase
//
//  Created by ellisbrandon20 on 10/9/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit

class ScanResultsTableViewCell: UITableViewCell {

   
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
