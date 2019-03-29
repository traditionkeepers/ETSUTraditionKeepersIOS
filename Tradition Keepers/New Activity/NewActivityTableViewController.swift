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
    
    // MARK: - Outlets
    @IBOutlet weak var TitleTextField: UITextField!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var InstructionsTextBox: UITextView!
    
    // MARK: - Actions
    @IBAction func UnwindToNewActivity(unwindSegue: UIStoryboardSegue) {
        if let vc = unwindSegue.source as? NewCategoryTableViewController {
            workingActivity.activity_data["category"] = vc.selectedCategory?.name
        }
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TitleTextField.text = workingActivity.activity_data["title"] as? String
        CategoryLabel.text = workingActivity.activity_data["category"] as? String
        setTextBoxText(text: workingActivity.activity_data["instruction"] as! String)
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
            workingActivity.activity_data["title"] = tb.text ?? ""
        } else if let tb = sender as? UITextView {
            workingActivity.activity_data["instruction"] = tb.text
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
            workingActivity.activity_data["instruction"] = textView.text
        }
    }
}

//MARK: - Firebase
extension NewActivityTableViewController {
    
    func UpdateDatabase(activity: Activity) {
        if let id = activity.id {
            Activity.db.collection("activities").document(id).setData(activity.activity_data) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        } else {
            Activity.db.collection("activities").document().setData(activity.activity_data) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
        
        
        let category = activity.activity_data["category"] as! String
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
