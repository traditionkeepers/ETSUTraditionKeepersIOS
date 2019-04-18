//
//  AuthViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/17/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {
    
    @IBOutlet var ActivityStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser?.email)
            User.FetchUserData { (error) in
                if let error = error {
                    print("Error fetching user information: \(error.localizedDescription)")
                }
                self.performSegue(withIdentifier: "ContinueToApplication", sender: nil)
            }
        } else {
            print("Not logged in!")
            User.current = User()
            performSegue(withIdentifier: "ContinueToApplication", sender: nil)
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
