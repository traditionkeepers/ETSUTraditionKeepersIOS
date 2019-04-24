//
//  NewUserViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class NewUserViewController: UIViewController, UITextFieldDelegate {
    
    var _email: String!
    var _password: String!
    var _firstName: Bool!
    var _lastName: Bool!
    var _eNumber: Bool!
    var db: Firestore {
        return Firestore.firestore()
    }
    
    let green = UIColor(red: 8/255, green: 175/255, blue: 70/255, alpha: 1)
    
    @IBOutlet weak var eNumberField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var SubmitButton: UIButton!
    
    func prepareView() {
        SubmitButton.layer.cornerRadius = 10
        firstNameField.delegate = self
        lastNameField.delegate = self
        eNumberField.delegate = self
        
        firstNameField.returnKeyType = .next
        lastNameField.returnKeyType = .next
        eNumberField.returnKeyType = .done
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        prepareView()
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
        
        if textField == lastNameField {
            eNumberField.becomeFirstResponder()
        }
        
        return true
    }
    
    @IBAction func firstNameDidEndEditing(_ sender: UITextField) {
        let text = sender.text
        _firstName = text?.range(of: "^([A-Za-z]+)[']?( ?([A-Za-z]+))*$", options: .regularExpression) != nil
        
        if !_firstName {
            sender.setRightViewIcon(icon: .linearIcons(.crossCircle), rightViewMode: .always, textColor: .red, backgroundColor: .clear, size: nil)
        } else {
            sender.setRightViewIcon(icon: .linearIcons(.checkmarkCircle), rightViewMode: .always, textColor: green, backgroundColor: .clear, size: nil)
        }
    }
    
    @IBAction func lastNameDidEndEditing(_ sender: UITextField) {
        let text = sender.text
        _lastName = text?.range(of: "^([A-Za-z]+)[']?( ?([A-Za-z]+))*$", options: .regularExpression) != nil
        
        if !_lastName {
            sender.setRightViewIcon(icon: .linearIcons(.crossCircle), rightViewMode: .always, textColor: .red, backgroundColor: .clear, size: nil)
        } else {
            sender.setRightViewIcon(icon: .linearIcons(.checkmarkCircle), rightViewMode: .always, textColor: green, backgroundColor: .clear, size: nil)
        }
    }
    
    @IBAction func eNumberDidEndEditing(_ sender: UITextField) {
        let text = sender.text
        _eNumber = text?.range(of: "E[0-9]{8}", options: .regularExpression) != nil
        
        if !_eNumber {
            sender.setRightViewIcon(icon: .linearIcons(.crossCircle), rightViewMode: .always, textColor: .red, backgroundColor: .clear, size: nil)
        } else {
            sender.setRightViewIcon(icon: .linearIcons(.checkmarkCircle), rightViewMode: .always, textColor: green, backgroundColor: .clear, size: nil)
        }
    }
    
    @IBAction func NewUserAndLogin(_ sender: Any) {
        guard _firstName && _lastName && _eNumber else { return }
        
        Auth.auth().createUser(withEmail: _email, password: _password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "Uh Oh...",
                                              message: "Your account could not be created at this time. Please try again.",
                                              preferredStyle: UIAlertController.Style.alert )
                let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (_) in
                    print("User Confirmed")
                    self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
                })
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            }
            else if let user = user {
                print("Sign Up Successful. \(user.user.uid)")
                let green = UIColor(red: 8/255, green: 175/255, blue: 70/255, alpha: 1)
                self.firstNameField.setRightViewIcon(icon: .linearIcons(.checkmarkCircle), rightViewMode: .always, textColor: green, backgroundColor: .clear, size: nil)
                self.lastNameField.setRightViewIcon(icon: .linearIcons(.checkmarkCircle), rightViewMode: .always, textColor: green, backgroundColor: .clear, size: nil)
                self.eNumberField.setRightViewIcon(icon: .linearIcons(.checkmarkCircle), rightViewMode: .always, textColor: green, backgroundColor: .clear, size: nil)
                
                var ref: DocumentReference? = nil
                ref = self.db.collection("users").document(user.user.uid)
                ref?.setData( [
                    "first": self.firstNameField.text!,
                    "last": self.lastNameField.text!,
                    "eNumber": self.eNumberField.text!,
                    "permission": "user"
                ]) { err in
                    if let err = err {
                        let user = Auth.auth().currentUser
                        user?.delete { error in
                            if let error = error {
                                print(error)
                            } else {
                                print("User successfully removed!")
                            }
                        }
                        let alert = UIAlertController(title: "Oh Oh...",
                                                      message: "Your account could not be created at this time. Please try again.",
                                                      preferredStyle: UIAlertController.Style.alert )
                        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (_) in
                            print("User Confirmed")
                            self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
                        })
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                        print("Error adding document: \(err)")
                        
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        let alert = UIAlertController(title: "Account Created",
                                                      message: "Your account has been successfully created! Please login with your entered credentials to begin.",
                                                      preferredStyle: UIAlertController.Style.alert )
                        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (_) in
                            print("User Confirmed")
                            self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
                        })
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
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
