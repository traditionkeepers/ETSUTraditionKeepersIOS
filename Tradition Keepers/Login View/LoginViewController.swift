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
    var currentUser: User!
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let enteredEmail = emailField.text! + "@etsu.edu"
        let enteredPassword = passwordField.text!
        
        if loadUser(email: enteredEmail, password: enteredPassword) {
            performSegue(withIdentifier: "login", sender: nil)
        } else {
            performSegue(withIdentifier: "newUser", sender: nil)
        }
    }
    
    func loadUser(email: String, password: String) -> Bool {
        // Cheack if user ETSU credentials correct
        let valid_auth = false
        
        if valid_auth {
            
        } else {
            // Check if user in Firebase
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
                guard let strongSelf = self else { return }
            }
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
                case "login":
                    if let vc = segue.destination as? NavTabBarController {
                        vc.currentUser = currentUser
                }
                //case "newUser":
                //if let vc = segue.destination as? UINavigationController {
                        // vc.currentUser = currentUser
                        // vc.store = self.store
                //}
                
                default: break
            }
        }
    }

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
}
