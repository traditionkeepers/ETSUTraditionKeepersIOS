//
//  TraditionTableViewCell.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/12/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class TraditionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var RequirementLabel: UILabel!
    @IBOutlet weak var SubmitButton: UIButton!
    
    var tradition: Tradition! {
        didSet {
            NameLabel.text = tradition.title
            RequirementLabel.text = tradition.requirement.title
            SubmitButton.setTitle(tradition.submission.status.rawValue, for: .normal)
            
            if tradition.isRequired {
                RequirementLabel.textColor = UIColor(named: "ETSU GOLD")
            } else {
                RequirementLabel.textColor = UIColor(named: "ETSU WHITE")
            }
            
            switch User.current.permission {
            case .none:
                SubmitButton.isHidden = true
            default:
                SubmitButton.isHidden = false
            }
            
            if tradition.submission.status == .none {
                SubmitButton.tintColor = UIColor(named: "ETSU GOLD")
            } else {
                SubmitButton.tintColor = UIColor(named: "ETSU WHITE")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sizeToFit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    class func cellForTableView(tableView: UITableView, atIndex indexPath: IndexPath) -> TraditionTableViewCell {
        let identifier = "TraditionCell"
        tableView.register(UINib(nibName: "TraditionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TraditionTableViewCell
        
        return cell
    }
    
    @IBAction func CompleteButtonPressed(_ sender: Any) {
        CompleteButtonPressed?(self)
    }
    
    var CompleteButtonPressed : ((UITableViewCell) -> Void)?
}
