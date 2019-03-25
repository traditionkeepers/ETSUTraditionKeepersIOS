//
//  LoginViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/9/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    var user: User! {
        didSet {
            User.currentUser = user
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let enteredEmail = emailField.text! + "@etsu.edu"
        let enteredPassword = passwordField.text!
        
        Auth.auth().signIn(withEmail: enteredEmail, password: enteredPassword) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.performSegue(withIdentifier: "newUser", sender: nil)
            } else if user != nil {
                self.GetUserData()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? NewUserViewController {
            vc._email = emailField.text! + "@etsu.edu"
            vc._password = passwordField.text!
        }
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToLogin(unwindSegue: UIStoryboardSegue) {
        emailField.text = ""
        passwordField.text = ""
    }
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
}

extension LoginViewController {
    func GetUserData() {
        print("Fetching User Data")
        let docref = Activity.db.collection("users").document(User.uid)
        docref.getDocument(completion: { (document, error) in
            if let document = document, document.exists {
                print("User Found!")
                self.user = User(fromDoc: document)
            } else {
                print("Error fetching user doc! \(String(describing: error))")
            }
        })
    }
}
