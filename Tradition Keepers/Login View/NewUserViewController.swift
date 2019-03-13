//
//  NewUserViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class NewUserViewController: UIViewController {
    
    var _email: String!
    var _password: String!
    var db: Firestore!
    
    @IBOutlet weak var eNumberField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()

        // Do any additional setup after loading the view.
    }
    @IBAction func NewUserAndLogin(_ sender: Any) {
        Auth.auth().createUser(withEmail: _email, password: _password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "Oh Oh...",
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
                print("Sign Up Successfully. \(user.user.uid)")
                
                var ref: DocumentReference? = nil
                ref = self.db.collection("users").document(user.user.uid)
                ref?.setData( [
                    "first": self.firstNameField.text!,
                    "last": self.lastNameField.text!,
                    "eNumber": self.eNumberField.text!
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
