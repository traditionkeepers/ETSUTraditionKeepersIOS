//
//  SubmissionButton.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/18/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class SubmissionButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func configureButton(status: ActivityStatus) {
        var titleText = ""
        var textColor = UIColor(named: "ETSU NAVY")
        var backgroundColor = UIColor(named: "ETSU WHITE")
        switch status {
        case .none:
            titleText = Permission.allowSubmission ? "Submit" : titleText
//            textColor = Permission.allowSubmission ? UIColor(named: "ETSU GOLD") : textColor
            backgroundColor = Permission.allowSubmission ? UIColor(named: "ETSU GOLD") : backgroundColor
        case .pending:
            titleText = Permission.allowSubmission ? "Pending" : titleText
            titleText = Permission.allowApproval ? "Verify" : titleText
//            textColor = Permission.allowApproval ? UIColor(named: "ETSU GOLD") : textColor
            backgroundColor = Permission.allowApproval ? UIColor(named: "ETSU GOLD") : backgroundColor
        case .complete:
            titleText = "Complete"
            textColor = UIColor(named: "ETSU WHITE")
            backgroundColor = .clear
        }
        
        setTitle(titleText, for: .normal)
        setTitleColor(textColor, for: .normal)
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 10
        isHidden = User.current.permission == .none
    }
}
