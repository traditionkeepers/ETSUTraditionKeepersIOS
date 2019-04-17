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

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return nil }
        
        return UIAlertAction(title: title, style: .default, handler: { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        })
    }
    
    func present(from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take Photo") {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera Roll") {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .photoLibrary, title: "Photo Library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
    
}

extension ImagePicker: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {
}
//    func submit(tradition: Tradition) {
//        ShowPrompt(tradition: tradition)
//    }
//
//    /// Shows an Alert prompting for submission. Shows optional UIImage if WithCamera() is used.
//    private func ShowPrompt(tradition: Tradition) {
//        // TODO: if submission image is set, format alert without image
//        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
//        let imageView = UIImageView(frame: CGRect(x: 10, y: 82, width: 250, height: 187.5))
//        imageView.image = submissionImage
//        alert.view.addSubview(imageView)
//        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
//        let width = NSLayoutConstraint(item: alert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
//        alert.view.addConstraint(height)
//        alert.view.addConstraint(width)
//
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
//            alert.dismiss(animated: true, completion: nil)
//        }
//
//        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
//            var tradition = tradition
//            tradition.submission = SubmittedTradition(status: .pending,
//                                                      user: User.current.uid,
//                                                      completion_date: Date(),
//                                                      tradition: tradition.title,
//                                                      location: nil,
//                                                      image: nil)
//            //self.submit(tradition)
//            alert.dismiss(animated: true, completion: nil)
//        }
//
//        alert.addAction(cancel)
//        alert.addAction(submit)
//        print("Showing Prompt For Submission!")
//        present(alert, animated: true, completion: nil)
//    }
//
//
//    private func getImage () {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//
//        let actionSheet = UIAlertController(title: "Choose a source", message: "", preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
//            imagePickerController.sourceType = .camera
//            self.present(imagePickerController, animated: true, completion: nil)
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
//            imagePickerController.sourceType = .photoLibrary
//            self.present(imagePickerController, animated: true, completion: nil)
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(actionSheet, animated: true, completion: nil)
//    }
//
//    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    //  sets submission image.  Up to ShowPrompt to show alert
//    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        submissionImage = image
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    private func submit(_ tradition: Tradition){
//        if tradition.id != "" {
//            let batch = SubmitViewController.db.batch()
//            let submissionRef = SubmitViewController.db.collection("submissions").document()
//            batch.setData(tradition.submissionDictionary, forDocument: submissionRef)
//
//            let userRef = SubmitViewController.db.collection("users").document(User.current.uid)
//            batch.updateData([tradition.requirement.id: FieldValue.increment(Int64(1))], forDocument: userRef)
//
//            batch.commit { (error) in
//                if let error = error {
//                    print("Error writing document: \(error)")
//                } else {
//                    print("Activity successfully added to database!")
//                }
//            }
//        }
//    }
//}
