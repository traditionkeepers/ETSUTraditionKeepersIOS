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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ssb = UIStoryboard(name: "Settings", bundle: .main)
        let settings = ssb.instantiateInitialViewController()
        settings?.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 4)
        
        switch User.permission {
        case .none:
            viewControllers = [settings!]
            tabBar.isHidden = true
            
        case .user:
            let dbsb = UIStoryboard(name: "Dashboard", bundle: .main)
            let dashboard = dbsb.instantiateInitialViewController()
            dashboard?.tabBarItem = UITabBarItem(title: "Dashboard", image: nil, tag: 0)
            
            let tsb = UIStoryboard(name: "Traditions", bundle: .main)
            let tradition = tsb.instantiateInitialViewController()
            tradition?.tabBarItem = UITabBarItem(title: "Traditions", image: nil, tag: 1)
                
            viewControllers = [dashboard!, tradition!, settings!]
            tabBar.isHidden = false
            
        case .staff, .admin:
            let dbsb = UIStoryboard(name: "Dashboard", bundle: .main)
            let dashboard = dbsb.instantiateInitialViewController()
            dashboard?.tabBarItem = UITabBarItem(title: "Dashboard", image: nil, tag: 0)
            
            let tsb = UIStoryboard(name: "Traditions", bundle: .main)
            let tradition = tsb.instantiateInitialViewController()
            tradition?.tabBarItem = UITabBarItem(title: "Traditions", image: nil, tag: 1)
            
            let usb = UIStoryboard(name: "Users", bundle: .main)
            let users = usb.instantiateInitialViewController()
            users?.tabBarItem = UITabBarItem(title: "Users", image: nil, tag: 2)
            
            let subsb = UIStoryboard(name: "Submissions", bundle: .main)
            let submissions = subsb.instantiateInitialViewController()
            submissions?.tabBarItem = UITabBarItem(title: "Submissions", image: nil, tag: 3)
            
            viewControllers = [dashboard!, tradition!, users!, submissions!, settings!]
            tabBar.isHidden = false
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
