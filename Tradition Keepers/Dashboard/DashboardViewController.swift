//
//  DashboardViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/25/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func fillData() {
        usernameButton.setTitle("Welcome, \(User.first) \(User.last)", for: UIControl.State.normal)
        progressButton.setTitle("Progress: \(User.uid)%", for: UIControl.State.normal)
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
