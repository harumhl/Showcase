//
//  ContributionsTableViewCell.swift
//  Showcase
//
//  Created by Brian Ta on 11/20/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit

class ContributionsTableViewCell: UITableViewCell {

    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var storeAddress: UILabel!
    @IBOutlet weak var numVisits: UILabel!
    @IBOutlet weak var amtContributed: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
