//
//  ActivityTableViewCell.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class ActivityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var SecondaryLabel: UILabel!
    @IBOutlet weak var CompleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func CompleteButtonPressed(_ sender: Any) {
        CompleteButtonPressed?(self)
    }
    
    var CompleteButtonPressed : ((UITableViewCell) -> Void)?
}
