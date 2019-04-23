//
//  NavTabBarController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/25/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import SwiftIcons

class NavTabBarController: UITabBarController {
    
    private var initialLoad = true
    private var tabs: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        updateTabs()
    }
    
    private func configureTabs() {
        tabs.removeAll()
        if let dashboard = Permission.dashboard ? UIStoryboard(name: "Dashboard", bundle: .main).instantiateInitialViewController()! : nil {
            dashboard.tabBarItem = UITabBarItem(title: "Dashboard", image: nil, tag: 0)
            dashboard.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            dashboard.tabBarItem.setIcon(icon: .linearIcons(.home), size: nil, textColor: .lightGray, backgroundColor: .clear, selectedTextColor: .black, selectedBackgroundColor: .clear)
            tabs.append(dashboard)
        }
        
        if let traditions = Permission.traditions ? UIStoryboard(name: "Traditions", bundle: .main).instantiateInitialViewController()! : nil {
            traditions.tabBarItem = UITabBarItem(title: "Traditions", image: nil, tag: 1)
            traditions.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            traditions.tabBarItem.setIcon(icon: .linearIcons(.map), size: nil, textColor: .lightGray, backgroundColor: .clear, selectedTextColor: .black, selectedBackgroundColor: .clear)
            tabs.append(traditions)
        }
        
        if let users = Permission.users ? UIStoryboard(name: "Users", bundle: .main).instantiateInitialViewController()! : nil {
            users.tabBarItem = UITabBarItem(title: "Users", image: nil, tag: 2)
            users.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            users.tabBarItem.setIcon(icon: .linearIcons(.users), size: nil, textColor: .lightGray, backgroundColor: .clear, selectedTextColor: .black, selectedBackgroundColor: .clear)
            tabs.append(users)
        }
        
        if let submissions = Permission.submissions ? UIStoryboard(name: "Submissions", bundle: .main).instantiateInitialViewController()! : nil {
            submissions.tabBarItem = UITabBarItem(title: "Submissions", image: nil, tag: 3)
            submissions.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            submissions.tabBarItem.setIcon(icon: .linearIcons(.list), size: nil, textColor: .lightGray, backgroundColor: .clear, selectedTextColor: .black, selectedBackgroundColor: .clear)
            tabs.append(submissions)
        }
        
        // Settings
        if let settings = Permission.settings ? UIStoryboard(name: "Settings", bundle: .main).instantiateInitialViewController()! : nil {
            settings.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 4)
            settings.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            settings.tabBarItem.setIcon(icon: .linearIcons(.cog), size: nil, textColor: .lightGray, backgroundColor: .clear, selectedTextColor: .black, selectedBackgroundColor: .clear)
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
    }
}
