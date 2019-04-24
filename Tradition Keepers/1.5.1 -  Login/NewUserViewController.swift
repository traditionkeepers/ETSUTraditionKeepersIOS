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
    var _firstName: String!
    var _lastName: String!
    var _eNumber: String!
    var db: Firestore {
        return Firestore.firestore()
    }
    
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
    
    @IBAction func checkFirstName(_ sender: Any) {
        let fNameBool = _firstName.range(of: #"\A\D+\b"#, options: .regularExpression) != nil
        
        if fNameBool == false {
            print("Executed Check - First Name")
            self.firstNameField.setRightViewIcon(icon: .linearIcons(.crossCircle), rightViewMode: .always, textColor: .red, backgroundColor: .clear, size: nil)
        }
    }
    
    @IBAction func checkLastName(_ sender: Any) {
        let lNameBool = _lastName.range(of: #"\A\D+\b"#, options: .regularExpression) != nil
        
        if lNameBool == false {
            print("Executed Check - Last Name")
            self.lastNameField.setRightViewIcon(icon: .linearIcons(.crossCircle), rightViewMode: .always, textColor: .red, backgroundColor: .clear, size: nil)
        }
    }
    
    @IBAction func checkENumber(_ sender: Any) {
        
    }
    
    @IBAction func NewUserAndLogin(_ sender: Any) {
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
