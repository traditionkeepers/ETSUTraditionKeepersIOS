//
//  LoginViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/9/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

/// Class for managing the Login View Controller
class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    // MARK: - Actions
    
    /// Action to be completed when the Login button is tapped.
    /// Authenticates the credentials with Firebase server
    ///
    /// - Parameter sender: the Button object that triggered the action
    @IBAction func LoginButtonTapped(_ sender: UIButton) {
        let enteredEmail = emailField.text! + "@etsu.edu"
        let enteredPassword = passwordField.text!
        
        User.LogIn(username: enteredEmail, password: enteredPassword, completion: { error in
            if let _error = error {
                if let errorCode = AuthErrorCode(rawValue: _error._code) {
                    print(error.debugDescription)
                    switch errorCode {
                    case .wrongPassword:
                        //Show Alert
                        break
                    default:
                        self.performSegue(withIdentifier: "New User", sender: nil)
                    }
                }
            } else {
                self.performSegue(withIdentifier: "Instructions", sender: nil)
            }
        })
    }
    
    
    /// Dismisses the modal view when user presses designated button.
    ///
    /// - Parameter sender: The object that triggered the action.
    @IBAction func DismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /// Segue to allow unwinding from another view controller.
    /// Resets the text fields.
    ///
    /// - Parameter unwindSegue: The segue that triggered the action.
    @IBAction func UnwindToLogin(unwindSegue: UIStoryboardSegue) {
        emailField.text = ""
        passwordField.text = ""
    }
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginButton.layer.cornerRadius = 10
    }
    
    
    /// Configures the destination view controllers when a segue is triggered
    ///
    /// - Parameters:
    ///   - segue: The triggered segue
    ///   - sender: The object that called the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? NewUserViewController {
            vc._email = emailField.text! + "@etsu.edu"
            vc._password = passwordField.text!
        }
    }
}
