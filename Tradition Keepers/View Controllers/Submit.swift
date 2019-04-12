//
//  Submit.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/10/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import MobileCoreServices

/// Provides functions for submitting traditions.
class Submit: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    /// Submits a tradition using the camera for verification.
    
    private static var sender: UIViewController!
    
    private static var submissionImage: UIImage!
    
    static func SetSender(callingView: UIViewController) {
        sender = callingView
    }
    
    static func WithCamera(callingView: UIViewController) {
        getImage()
    }
    
    /// Submits a tradition using a prompt for verification.
    static func WithPrompt() {
        
    }
    
    /// Shows an Alert prompting for submission. Shows optional UIImage if WithCamera() is used.
    private static func ShowPrompt(selectedActivity: Activity, activity: Activity) {
        // TO DO: if submission image is set, format alert without image
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 82, width: 250, height: 187.5))
        imageView.image = submissionImage
        alert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        let width = NSLayoutConstraint(item: alert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            selectedActivity.completion.status = .pending
            selectedActivity.completion.user_id = User.uid
            selectedActivity.completion.activity_ref = Activity.db.document("activities/\(selectedActivity.id ?? "")")
            selectedActivity.completion.date = Date()
            UpdateDatabase(activity: selectedActivity)
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        sender.present(alert, animated: true, completion: nil)
    }
    
    
    private static func getImage () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = sender as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        let actionSheet = UIAlertController(title: "Choose a source", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .camera
            sender.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            sender.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    

    
    private static func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //  sets submission image.  Up to ShowPrompt to show alert
    private static func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        submissionImage = image
        picker.dismiss(animated: true, completion: nil)
    }
}
