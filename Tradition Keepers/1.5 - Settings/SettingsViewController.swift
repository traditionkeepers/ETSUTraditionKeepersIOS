//
//  DefaultLaunchViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/22/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

/// View Controller for the Settings View
class SettingsViewController: UIViewController {
    
    /// Determines if the Navigation Bar is visible
    private var showNavBar = false
    private var initialView = false
    
    @IBOutlet weak var LoginProfileButton: UIButton!
    @IBOutlet weak var LogoutButton: UIButton!
    @IBOutlet weak var TraditionsButton: UIButton!
    
    
    
    /// Code to be executed when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialView = User.current.permission == .none
        // Do any additional setup after loading the view.
    }
    
    
    /// Configures the view for the current user's permissions
    fileprivate func setupView() {
        print("Updating Settings")
        switch User.current.permission {
        case .none:
            
            LoginProfileButton?.setTitle("Login", for: .normal)
            TraditionsButton.isHidden = false
            LogoutButton.isHidden = true
            
        default:
            LoginProfileButton.setTitle("Profile", for: .normal)
            TraditionsButton.isHidden = true
            LogoutButton.isHidden = false
        }
        
//        if let tc = self.tabBarController as? NavTabBarController {
//            tc.updateTabs()
//        }
    }
    
    
    /// The following code runs whenever the view is about to appear in view
    /// Hides the Navigation Bar from view
    ///
    /// - Parameter animated: Should animation be displayed
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavBar = false
        navigationController?.setNavigationBarHidden(!showNavBar, animated: animated)
        
        self.setupView()
        if initialView {
            initialView = false
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    
    /// The following code runs whenever the view is about to disappear from view
    /// Shows the Navigation Bar for all views except "Login"
    ///
    /// - Parameter animated: Should animation be displayed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if showNavBar {
            navigationController?.setNavigationBarHidden(!showNavBar, animated: true)
        }
    }
    
    
    /// Perform Logout Action when the button is pressed
    ///
    /// - Parameter sender: The object that triggered the action
    @IBAction func LogoutButtonPressed(_ sender: Any) {
        print("Logging Out")
        initialView = true
        User.LogOut()
        setupView()
        if let tb = self.tabBarController as? NavTabBarController {
            tb.updateTabs()
        }
    }
    
    
    /// Action to be performed when the Login/Profile button is pressed
    ///
    /// - Parameter sender: The object that triggered the action
    @IBAction func LoginProfileButtonPressed(_ sender: Any) {
        switch User.current.permission {
        case .none:
            performSegue(withIdentifier: "Login", sender: nil)
        default:
            performSegue(withIdentifier: "Profile", sender: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    /// Code to be executed whenever a segue the triggered
    /// Sets "showNavBar" to true for all segues except "Login"
    ///
    /// - Parameters:
    ///   - segue: the triggered segue
    ///   - sender: The object that triggered the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier != "Login" {
            showNavBar = true
        }
    }

}
