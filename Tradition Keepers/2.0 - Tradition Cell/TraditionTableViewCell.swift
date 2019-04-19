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
    @IBOutlet var SubmitButton: SubmissionButton!
    
    private var DateFormat = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sizeToFit()
        
        DateFormat.dateStyle = .short
        DateFormat.timeStyle = .none
        DateFormat.locale = Locale(identifier: "en_US")
    }
    
    private func configureCell(tradition: Tradition) {
        NameLabel.text = tradition.title
        RequirementLabel.textColor = tradition.isRequired ? UIColor(named: "ETSU GOLD") : UIColor(named: "ETSU WHITE")
        RequirementLabel.text = tradition.requirement.title
        
        SubmitButton.configureButton(status: tradition.submission.status)
    }
    
    private func configureCell(submission: SubmittedTradition) {
        NameLabel.text = submission.tradition
        RequirementLabel.textColor = UIColor(named: "ETSU WHITE")
        RequirementLabel.text = "\(submission.user) - \(DateFormat.string(from: submission.completion_date))"
        
        SubmitButton.configureButton(status: submission.status)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    class func cellForTableView(tableView: UITableView, atIndex indexPath: IndexPath, tradition: Tradition?) -> TraditionTableViewCell {
        let identifier = "TraditionCell"
        tableView.register(UINib(nibName: "TraditionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TraditionTableViewCell
        
        if let data = tradition {
            cell.configureCell(tradition: data)
        } else {
            print("No valid Tradition provided!")
        }
        return cell
    }
    
    class func cellForTableView(tableView: UITableView, atIndex indexPath: IndexPath, submission: SubmittedTradition?) -> TraditionTableViewCell {
        let identifier = "TraditionCell"
        tableView.register(UINib(nibName: "TraditionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TraditionTableViewCell
        
        if let data = submission {
            cell.configureCell(submission: data)
        } else {
            print("No valid Submission provided!")
        }
        return cell
    }
    
    @IBAction func CompleteButtonPressed(_ sender: Any) {
        CompleteButtonPressed?(self)
    }
    
    var CompleteButtonPressed : ((UITableViewCell) -> Void)?
}
