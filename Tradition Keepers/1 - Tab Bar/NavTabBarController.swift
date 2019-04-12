//
//  NavTabBarController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/25/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class NavTabBarController: UITabBarController {
    
    private var initialLoad = true
    private var tabs: [ UserPermission:[UIViewController] ] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
        updateTabs()
        // Do any additional setup after loading the view.
    }
    
    func configureTabs() {
        let dashboard = UIStoryboard(name: "Dashboard", bundle: .main).instantiateInitialViewController()!
        dashboard.tabBarItem = UITabBarItem(title: "Dashboard", image: nil, tag: 0)
            
        let traditions = UIStoryboard(name: "Traditions", bundle: .main).instantiateInitialViewController()!
        traditions.tabBarItem = UITabBarItem(title: "Traditions", image: nil, tag: 1)
        
        let usb = UIStoryboard(name: "Users", bundle: .main)
        let users = usb.instantiateInitialViewController()!
        users.tabBarItem = UITabBarItem(title: "Users", image: nil, tag: 2)

        let subsb = UIStoryboard(name: "Submissions", bundle: .main)
        let submissions = subsb.instantiateInitialViewController()!
        submissions.tabBarItem = UITabBarItem(title: "Submissions", image: nil, tag: 3)
        
        // Settings
        let settings = UIStoryboard(name: "Settings", bundle: .main).instantiateInitialViewController()!
        settings.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 4)
        
        tabs[.none] = [settings]
        tabs[.user] = [dashboard, traditions, settings]
        tabs[.staff] = [dashboard, traditions, users, submissions, settings]
        tabs[.admin] = [dashboard, traditions, users, submissions, settings]
        
//        tabs?[.staff] = [dashboard!, tradition!, users!, submissions!, settings!]
//        tabs?[.admin] = [dashboard!, tradition!, users!, submissions!, settings!]
        
    }
    
    func updateTabs() {
        self.setViewControllers(tabs[User.current.permission], animated: true)
        print("Updating Tabs")
        switch User.current.permission {
        case .none:
            self.tabBar.isHidden = true
        default:
            self.tabBar.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        User.onUpdate = { user in
            self.updateTabs()
//        }
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
