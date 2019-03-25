//
//  DefaultLaunchViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/22/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    private var showNavBar = false
    
    @IBOutlet weak var LoginProfileButton: UIButton!
    @IBOutlet weak var LogoutButton: UIButton!
    @IBOutlet weak var TraditionsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }
    
    private func setupView() {
        switch User.permission {
        case .none:
            LoginProfileButton?.setTitle("Login", for: .normal)
            TraditionsButton.isHidden = false
            LogoutButton.isHidden = true
            
        default:
            LoginProfileButton.setTitle("Profile", for: .normal)
            TraditionsButton.isHidden = true
            LogoutButton.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavBar = false
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if showNavBar {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    @IBAction func LogoutButtonPressed(_ sender: Any) {
        // Logout Code
    }
    
    @IBAction func LoginProfileButtonPressed(_ sender: Any) {
        switch User.permission {
        case .none:
            performSegue(withIdentifier: "Login", sender: nil)
        default:
            performSegue(withIdentifier: "Profile", sender: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier != "Login" {
            showNavBar = true
        }
    }

}
