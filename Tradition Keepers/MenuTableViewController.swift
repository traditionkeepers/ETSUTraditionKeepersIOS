//
//  MenuTableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/20/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    private enum menuItems: String {
        case profile = "Your Profile"
        case login = "Login"
        case logout = "Logout"
        case dashboard = "Dashboard"
        case tradition = "Traditions"
        case submission = "Submissions"
        case users = "Users"
        case about = "About"
    }
    
    private var userItems: [ UserPermission:[menuItems] ] = [
        UserPermission.none: [
            menuItems.login,
            menuItems.tradition,
            menuItems.about
        ],
        
        UserPermission.user: [
            menuItems.profile,
            menuItems.dashboard,
            menuItems.tradition,
            menuItems.about,
            menuItems.logout
        ],
        
        UserPermission.staff: [
            menuItems.profile,
            menuItems.users,
            menuItems.submission,
            menuItems.tradition,
            menuItems.about,
            menuItems.logout
        ],
        
        UserPermission.admin: [
            menuItems.profile,
            menuItems.users,
            menuItems.submission,
            menuItems.tradition,
            menuItems.about,
            menuItems.logout
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userItems[User.permission]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell
        // Configure the cell...
        cell.MenuTitle.text = userItems[User.permission]![indexPath.row].rawValue
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: userItems[User.permission]![indexPath.row].rawValue, sender: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
