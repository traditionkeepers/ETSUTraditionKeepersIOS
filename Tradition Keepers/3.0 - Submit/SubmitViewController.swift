//
//  SubmitViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/17/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class SubmitViewController: UITableViewController {
    @IBOutlet weak var TraditionNameLabel: UILabel!
    @IBOutlet weak var TraditionRequirementLabel: UILabel!
    @IBOutlet weak var CameraButton: UIButton!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var SubmissionImage: UIImageView!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var UserDateLabel: UILabel!
    @IBOutlet weak var ApprovalLabel: UILabel!
    @IBOutlet weak var ApprovalDateLabel: UILabel!
    @IBOutlet weak var CancelBarButton: UIBarButtonItem!
    @IBOutlet weak var SubmitBarButton: UIBarButtonItem!
    
    var imagePicker: ImagePicker!
    var tradition: Tradition!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        // Do any additional setup after loading the view.
    }
    
    private func prepareView() {
        //CameraButton.setIcon(icon: .linearIcons(.camera), forState: .normal)
        CameraButton.setIcon(icon: .linearIcons(.camera), iconSize: 50, color: UIColor(named: "ETSU GOLD")!, backgroundColor: UIColor(named: "ETSU GOLD")!, forState: .normal)
        TraditionNameLabel.text = tradition.title
        TraditionRequirementLabel.text = tradition.requirement.title
        UserNameLabel.text = User.current.name_FL
        
        
        // check for denial
        
        switch User.current.permission {
        case .staff, .admin:
            CancelBarButton.isEnabled = true
            SubmitBarButton.title = "Verify"
            SubmitBarButton.isEnabled = true
        default:
            UserNameLabel.text = User.current.name_FL
            //UserDateLabel.text = tradition.submission.completion_date
            CancelBarButton.isEnabled = true
            SubmitBarButton.title = "Save"
            SubmitBarButton.isEnabled = false
        }
        
        ApprovalLabel.isHidden = true
        ApprovalDateLabel.isHidden = true
        
        // Only show button for .pending and .complete state
        switch tradition.submission.status {
        case .pending:
            ApprovalLabel.isHidden = false
            ApprovalDateLabel.isHidden = false
            ApprovalLabel.text = "Awaiting Approval"
            
        case .complete:
            ApprovalDateLabel.isHidden = false
            ApprovalLabel.text = "Approved by"
            ApprovalDateLabel.text = ""
            
        default:
            ApprovalLabel.isHidden = true
            ApprovalDateLabel.isHidden = true
        }
    }
    
    func showAlertForSubmission () {
        print("Submit Button Pressed")
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            self.tradition.submission = SubmittedTradition(status: .pending,
                                                           user: User.current.name_FL,
                                                           completion_date: Date(),
                                                           tradition: self.tradition.id,
                                                           location: nil,
                                                           image: self.SubmissionImage.image)
            self.UpdateDatabase(activity: self.tradition)
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func UpdateDatabase(activity: Tradition) {
        if activity.id != "" {
            let ref = Firestore.firestore().collection("completed_activities")
            ref.document().setData(activity.submissionDictionary) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
    }
    
    @IBAction func CameraButtonTouchUpInside(_ sender: Any) {
        imagePicker.present(from: UIView())
    }
    
    @IBAction func SubmitButtonPressed(_ sender: Any) {
        switch User.current.permission {
        case .staff, .admin:
            tradition.submission.status = .complete
            let alert = UIAlertController(title: "Verify Submission", message: "Submission Verified", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            CancelBarButton.title = "Done"
        default:
            showAlertForSubmission()
        }
    }
    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        
        switch User.current.permission {
        case .staff, .admin:
            if (tradition.submission.status == .complete) {
                self.dismiss(animated: true, completion: nil)
                
            }
            
            print("Complete Button Pressed")
            let alert = UIAlertController(title: "Deny Submission", message: "Would you like to deny verification?", preferredStyle: .alert)
            let deny = UIAlertAction(title: "Yes", style: .cancel) { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                let denialReason = self.promptForDenialReason()
            }
            let cancel = UIAlertAction(title: "No", style: .default) { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
                // return to caller
            }
            
            alert.addAction(deny)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        default:
            self.dismiss(animated: true, completion: nil)
            // return to caller
            
        }
        
    }
    
    func promptForDenialReason() {
        let alert = UIAlertController(title: "Denial Reason", message: "Enter a reason for denial.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "Default text"
        }
        let ok = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            let textField = alert.textFields![0]
            // add reason for denial
            self.UpdateDatabase(activity: self.tradition)
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
            // return to caller
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

extension SubmitViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        print("Image Selected")
        SubmissionImage.image = image
        SubmitBarButton.isEnabled = true
    }
}
