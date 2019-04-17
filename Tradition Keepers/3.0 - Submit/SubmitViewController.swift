//
//  SubmitViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/17/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class SubmitViewController: UITableViewController {
    @IBOutlet weak var TraditionNameLabel: UILabel!
    @IBOutlet weak var TraditionRequirementLabel: UILabel!
    @IBOutlet weak var ApproveButton: UIButton!
    
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var SubmissionImage: UIImageView!
    
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var UserDateLabel: UILabel!
    
    @IBOutlet weak var ApprovalLabel: UILabel!
    @IBOutlet weak var ApprovalDateLabel: UILabel!
    
    @IBOutlet weak var DenyBarButton: UIBarButtonItem!
    @IBOutlet weak var DenyButton: UIButton!
    @IBOutlet weak var SubmitBarButton: UIBarButtonItem!
    
    var imagePicker: ImagePicker!
    var tradition: Tradition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        imagePicker.present(from: UIView())
        // Do any additional setup after loading the view.
    }
    
    private func prepareView() {
        
        // Only allow button presses for staff/admin
        switch User.current.permission {
        case .staff, .admin:
            ApproveButton.isEnabled = true
            DenyBarButton.isEnabled = true
            DenyButton.isHidden = false
        default:
            ApproveButton.isEnabled = false
            DenyBarButton.isEnabled = false
            DenyButton.isHidden = true
        }
        
        // Only show button for .pending and .complete state
        switch tradition.submission.status {
        case .pending, .complete:
            ApproveButton.isHidden = false
            SubmitBarButton.title = "Approve"
        default:
            ApproveButton.isHidden = true
        }
    }

    @IBAction func SubmitButtonPressed(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SubmitViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        print("Image Selected")
    }
}
