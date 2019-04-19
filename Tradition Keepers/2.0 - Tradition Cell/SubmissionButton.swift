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
        var data = ""
        var btnColor = UIColor(named: "ETSU WHITE")
        switch status {
        case .none:
            data = Permission.allowSubmission ? "Submit" : data
            btnColor = Permission.allowSubmission ? UIColor(named: "ETSU GOLD") : btnColor
        case .pending:
            data = Permission.allowSubmission ? "Pending" : data
            data = Permission.allowApproval ? "Verify" : data
            
            btnColor = Permission.allowApproval ? UIColor(named: "ETSU GOLD") : btnColor
        case .complete:
            data = "Complete"
        }
        
        print(data)
        setTitle(data, for: .normal)
        setTitleColor(btnColor, for: .normal)
        isHidden = User.current.permission == .none
    }
}
