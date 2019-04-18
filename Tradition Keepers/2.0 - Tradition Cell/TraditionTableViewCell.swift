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
    
    var tradition: Tradition?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sizeToFit()
    }
    
    private func configureCell() {
        guard let tradition = self.tradition else { return }
        
        NameLabel.text = tradition.title
        RequirementLabel.textColor = tradition.isRequired ? UIColor(named: "ETSU GOLD") : UIColor(named: "ETSU WHITE")
        RequirementLabel.text = tradition.requirement.title
        
        SubmitButton.setTitle(tradition.submission.status.rawValue, for: .normal)
        let btnColor = tradition.submission.status == .none ? UIColor(named: "ETSU GOLD") : UIColor(named: "ETSU WHITE")
        SubmitButton.setTitleColor(btnColor, for: .normal)
        SubmitButton.isHidden = User.current.permission == .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    class func cellForTableView(tableView: UITableView, atIndex indexPath: IndexPath, tradition: Tradition?) -> TraditionTableViewCell {
        let identifier = "TraditionCell"
        tableView.register(UINib(nibName: "TraditionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TraditionTableViewCell
        
        cell.tradition = tradition
        cell.configureCell()
        return cell
    }
    
    @IBAction func CompleteButtonPressed(_ sender: Any) {
        CompleteButtonPressed?(self)
    }
    
    var CompleteButtonPressed : ((UITableViewCell) -> Void)?
}
