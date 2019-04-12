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
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var InstructionsTextBox: UITextView!
    
    // MARK: - Actions
    @IBAction func UnwindToNewActivity(unwindSegue: UIStoryboardSegue) {
        if let vc = unwindSegue.source as? NewCategoryTableViewController {
            workingActivity.category = vc.category!
        }
        
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
        TitleDidEndEditing(TitleTextField!)
        textViewDidEndEditing(InstructionsTextBox)
        
        selectedActivity = workingActivity
        UpdateDatabase(tradition: selectedActivity)
        dismiss(animated: true, completion: nil)
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
        CategoryLabel.text = workingActivity.category.name
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
        print("Submitting \(tradition)")
        if tradition.id != "" {
            Firestore.firestore().collection("traditions").document(tradition.id).setData(tradition.activityDictionary) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        } else {
            Firestore.firestore().collection("traditions").document().setData(tradition.activityDictionary) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
        
        let category = tradition.category
        Firestore.firestore().collection("categories").document( category.name.lowercased() ).setData([
            "title": category.name
        ]) {err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                print("Successfully add category")
            }
        }
        
        if let location = location {
            Firestore.firestore().collection("locations").document(location.id).setData([
                "title": location.title,
                "coordinate": location.point
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    print("Successfully add location")
                }
            }
        }
    }
}
