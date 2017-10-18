//
//  ReviewTableViewCell.swift
//  Showcase
//
//  Created by ellisbrandon20 on 10/18/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reviewTitle: UILabel!
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet weak var reviewRating: CosmosView!
    
}
