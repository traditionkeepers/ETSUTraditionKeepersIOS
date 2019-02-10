//
//  LoginViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/9/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if validUser() {
            performSegue(withIdentifier: "login", sender: nil)
        } else {
            let alert = UIAlertController(title: "Invalid Email/Password", message: "Your entered email/password is incorrect. Please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
            emailField.text = ""
            passwordField.text = ""
        }
    }
    
    var validUsers: [String] = [
        "thally@etsu.edu",
        "default@etsu.edu"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // MARK: - Navigation
    
    func validUser() -> Bool {
        return validUsers.contains(emailField.text ?? "")
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let view = segue.destination as! MainEventTableViewController
        view.currentId = emailField.text ?? ""
    }

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
}
