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
class LoginViewController: UIViewController, UITextFieldDelegate {

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
            let green = UIColor(red: 8/255, green: 175/255, blue: 70/255, alpha: 1)
            self.emailField.setRightViewIcon(icon: .linearIcons(.checkmarkCircle), rightViewMode: .always, textColor: green, backgroundColor: .clear, size: nil)
            self.passwordField.setRightViewIcon(icon: .linearIcons(.checkmarkCircle), rightViewMode: .always, textColor: green, backgroundColor: .clear, size: nil)
            if let _error = error {
                if let errorCode = AuthErrorCode(rawValue: _error._code) {
                    print(error.debugDescription)
                    switch errorCode {
                    case .wrongPassword:
                        self.passwordField.setRightViewIcon(icon: .linearIcons(.crossCircle), rightViewMode: .always, textColor: .red, backgroundColor: .clear, size: nil)
                    case.invalidEmail:
                        self.emailField.setRightViewIcon(icon: .linearIcons(.crossCircle), rightViewMode: .always, textColor: .red, backgroundColor: .clear, size: nil)
                    default:
                        self.performSegue(withIdentifier: "New User", sender: nil)
                    }
                }
            } else {
                self.performSegue(withIdentifier: "Instructions", sender: nil)
                if let tb = self.tabBarController as? NavTabBarController {
                    tb.updateTabs()
                }
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
        emailField.rightView = nil
        passwordField.rightView = nil
    }
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        LoginButton.layer.cornerRadius = 10
        
        emailField.delegate = self
        emailField.returnKeyType = .next
        passwordField.delegate = self
        passwordField.returnKeyType = .done
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("next button should work")
        
        textField.resignFirstResponder()
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        return true
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
