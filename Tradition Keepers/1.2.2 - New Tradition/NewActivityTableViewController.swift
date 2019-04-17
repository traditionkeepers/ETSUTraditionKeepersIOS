//
//  NewActivityTableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/17/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class NewActivityTableViewController: UITableViewController {
    // MARK: - Properties
    private let db = Firestore.firestore()
    private var workingActivity = Tradition()
    var selectedActivity: Tradition! {
        didSet {
            workingActivity = selectedActivity
        }
    }
    var location: Location?
    
    // MARK: - Outlets
    @IBOutlet weak var TitleTextField: UITextField!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var InstructionsTextBox: UITextView!
    @IBOutlet var RequiredSwitch: UISwitch!
    
    // MARK: - Actions
    @IBAction func UnwindToNewActivity(unwindSegue: UIStoryboardSegue) {
        if let vc = unwindSegue.source as? NewLocationViewController {
            self.location = vc.selectedLocation
            if let point = self.location {
                self.workingActivity.location = point
            }
            print(self.location ?? "")
        }
    }
    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SaveButtonPressed(_ sender: Any)
    {
        print("Save Button Pressed!")
        TitleDidEndEditing(TitleTextField!)
        textViewDidEndEditing(InstructionsTextBox)
        
        UpdateDatabase(tradition: workingActivity)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func requiredChanged(_ sender: UISwitch) {
        workingActivity.requirement = (sender.isOn ? Requirement.required : Requirement.optional)
    }
    
    @IBAction func TitleDidBeginEditing(_ sender: Any) {
        guard let textField = sender as? UITextField else {
            return
        }
        
        if textField.textColor == UIColor.lightGray {
            textField.text = nil
            textField.textColor = UIColor.black
        }
        
    }
    
    @IBAction func TitleDidEndEditing(_ sender: Any) {
        guard let textField = sender as? UITextField else {
            return
        }
        if textField.text?.isEmpty ?? true {
            textField.text = "Title"
            textField.textColor = UIColor.lightGray
        } else {
            workingActivity.title = textField.text ?? ""
            self.title = textField.text ?? "New Activity"
        }
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TitleTextField.text = workingActivity.title
        setLocationText(text: workingActivity.location.title)
        RequiredSwitch.isOn = workingActivity.isRequired
        setInstructionText(text: workingActivity.instruction)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.topViewController as? NewLocationViewController {
                vc.selectedLocation = location
            }
        }
    }
    
    func setLocationText(text: String) {
        if text == "" {
            LocationLabel.text = "Location"
            LocationLabel.textColor = UIColor.lightGray
        } else {
            LocationLabel.text = text
            LocationLabel.textColor = nil
        }
    }
    
    func setInstructionText(text: String) {
        if text == "" {
            InstructionsTextBox.text = "User Instructions"
            InstructionsTextBox.textColor = UIColor.lightGray
        } else {
            InstructionsTextBox.text = text
            InstructionsTextBox.textColor = nil
        }
    }
}

// MARK: - Text View Delegate
extension NewActivityTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "User Instruction"
            textView.textColor = UIColor.lightGray
        } else {
            workingActivity.instruction = textView.text
        }
    }
}

//MARK: - Firebase
extension NewActivityTableViewController {
    
    func UpdateDatabase(tradition: Tradition) {
        print("Updating \(tradition)")
        let batch = db.batch()
        
        // Add tradition
        if tradition.id != "" {
            let traditionRef = db.collection("traditions").document(tradition.id)
            batch.setData(tradition.activityDictionary, forDocument: traditionRef)
        } else {
            let traditionRef = db.collection("traditions").document()
            batch.setData(tradition.activityDictionary, forDocument: traditionRef)
        }
        
        // Add/Increment counter for category
        let reqRef = db.collection("requirement").document(tradition.requirement.id)
        batch.setData(tradition.requirement.dictionary, forDocument: reqRef, merge: true)
        batch.updateData(["count": FieldValue.increment(Int64(1))], forDocument: reqRef)
        
        let locationRef = db.collection("locations").document(tradition.location.id)
        batch.setData(tradition.location.dictionary, forDocument: locationRef)
        
        // Commit changes
        batch.commit { (error) in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Tradition successfully added to database!")
            }
        }
    }
}
