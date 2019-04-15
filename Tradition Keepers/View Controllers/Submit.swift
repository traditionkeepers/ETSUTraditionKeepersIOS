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
class Submit: UIView, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    /// Submits a tradition using the camera for verification.
    private static var sender: UIViewController!
    private static var submissionImage: UIImage!
    
    static func WithCamera(callingView: UIViewController, tradition: Tradition) {
        sender = callingView
        getImage()
        ShowPrompt(tradition: tradition)
    }
    
    /// Submits a tradition using a prompt for verification.
    class func WithPrompt(callingView: UIViewController, tradition: Tradition) {
        sender = callingView
        ShowPrompt(tradition: tradition)
    }
    
    private static let db = Firestore.firestore()
    
    /// Shows an Alert prompting for submission. Shows optional UIImage if WithCamera() is used.
    private static func ShowPrompt(tradition: Tradition) {
        // TODO: if submission image is set, format alert without image
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 82, width: 250, height: 187.5))
        imageView.image = submissionImage
        alert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        let width = NSLayoutConstraint(item: alert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            var tradition = tradition
            tradition.submission = SubmittedTradition(status: .pending,
                                                             user: User.current.uid,
                                                             completion_date: Date(),
                                                             tradition: tradition.title,
                                                             location: nil,
                                                             image: nil)
            //self.submit(tradition)
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        print("Showing Prompt For Submission!")
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
        sender.present(actionSheet, animated: true, completion: nil)
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
    
    private class func submit(_ tradition: Tradition){
        if tradition.id != "" {
            let batch = db.batch()
            let submissionRef = db.collection("submissions").document()
            batch.setData(tradition.submissionDictionary, forDocument: submissionRef)
            
            let userRef = db.collection("users").document(User.current.uid)
            batch.updateData([tradition.category.name: FieldValue.increment(Int64(1))], forDocument: userRef)
            
            batch.commit { (error) in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
    }
}
