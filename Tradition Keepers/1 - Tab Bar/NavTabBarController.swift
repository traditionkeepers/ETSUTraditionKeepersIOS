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
    private var tabs: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureTabs() {
        if let dashboard = Permission.dashboard ? UIStoryboard(name: "Dashboard", bundle: .main).instantiateInitialViewController()! : nil {
            dashboard.tabBarItem = UITabBarItem(title: "Dashboard", image: nil, tag: 0)
            tabs.append(dashboard)
        }
        
        if let traditions = Permission.traditions ? UIStoryboard(name: "Traditions", bundle: .main).instantiateInitialViewController()! : nil {
            traditions.tabBarItem = UITabBarItem(title: "Traditions", image: nil, tag: 1)
            tabs.append(traditions)
        }
        
        if let users = Permission.users ? UIStoryboard(name: "Users", bundle: .main).instantiateInitialViewController()! : nil {
            users.tabBarItem = UITabBarItem(title: "Users", image: nil, tag: 2)
            tabs.append(users)
        }
        
        if let submissions = Permission.submissions ? UIStoryboard(name: "Submissions", bundle: .main).instantiateInitialViewController()! : nil {
            submissions.tabBarItem = UITabBarItem(title: "Submissions", image: nil, tag: 3)
            tabs.append(submissions)
        }
        
        // Settings
        if let settings = Permission.settings ? UIStoryboard(name: "Settings", bundle: .main).instantiateInitialViewController()! : nil {
            settings.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 4)
            tabs.append(settings)
        }
        print("Tabs: \(tabs)")
    }
    
    func updateTabs() {
        configureTabs()
        self.setViewControllers(tabs, animated: true)
        self.tabBar.isHidden = tabs.count < 2
        print("Updating Tabs")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTabs()
    }
}
