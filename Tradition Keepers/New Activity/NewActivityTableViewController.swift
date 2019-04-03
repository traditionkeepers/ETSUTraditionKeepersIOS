//
//  NewActivityTableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/17/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class NewActivityTableViewController: UITableViewController {
    // MARK: - Properties
    var currentUser: User!
    private var workingActivity = Activity()
    var selectedActivity: Activity! {
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
            workingActivity.category = vc.selectedCategory?.name ?? "Generic"
        }
        
        if let vc = unwindSegue.source as? NewLocationViewController {
            self.location = vc.selectedLocation
            print(self.location)
        }
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TitleTextField.text = workingActivity.title
        LocationLabel.text = location?.name
        CategoryLabel.text = workingActivity.category
        setTextBoxText(text: workingActivity.instruction)
    }
    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SaveButtonPressed(_ sender: Any) {
        selectedActivity = workingActivity
        UpdateDatabase(activity: selectedActivity)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DoneEditing(_ sender: Any) {
        if let tb = sender as? UITextField {
            workingActivity.title = tb.text ?? ""
        } else if let tb = sender as? UITextView {
            workingActivity.instruction = tb.text
        }
    }
    
    func setTextBoxText(text: String) {
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
    
    func UpdateDatabase(activity: Activity) {
        if let id = activity.id {
            Activity.db.collection("activities").document(id).setData(activity.Info) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        } else {
            Activity.db.collection("activities").document().setData(activity.Info) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
        
        
        let category = activity.category
        Activity.db.collection("categories").document( category.lowercased() ).setData([
            "title": category
        ]) {err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                print("Successfully add category")
            }
        }
    }
}
