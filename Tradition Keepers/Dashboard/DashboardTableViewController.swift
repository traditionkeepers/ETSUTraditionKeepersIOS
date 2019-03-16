//
//  TableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class DashboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var nearbyActivities = [
        ["Event 1", "Event 1 Description"],
        ["Event 2", "Event 2 Description"],
        ["Event 3", "Event 3 Description"]
    ]
    
    var currentUser: User = User() {
        didSet {
            let tabs = self.tabBarController?.viewControllers ?? []
            for tab in tabs {
                if let nc = tab as? UINavigationController {
                    if let vc = nc.topViewController as? ActivityCollectionViewController {
                        vc.currentUser = self.currentUser
                        print("Found Collection")
                    }
                } else {
                    print("Found Something Else")
                }
            }
            usernameButton.setTitle("Welcome, \(currentUser.data.first) \(currentUser.data.last)", for: UIControl.State.normal)
            progressButton.setTitle("Progress: \(currentUser.data.uid)%", for: UIControl.State.normal)
        }
    }
    
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GetUserData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func GetUserData() {
        let docref = Activity.db.collection("users").document(currentUser.data.uid)
        docref.getDocument(completion: { (document, error) in
            if let document = document, document.exists {
                self.currentUser = User(fromDoc: document)
            } else {
                print("Error fetching user doc! \(String(describing: error))")
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func pressedUserButton(_ sender: Any) {
        performSegue(withIdentifier: "ShowUserDetail", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "ShowActivityDetail":
            if let vc = segue.destination as? ActivityDetailViewController {
                vc.currentUser = self.currentUser
            }
        case "ShowUserDetail":
            if let vc = segue.destination as? ProfileViewController {
                vc.currentUser = self.currentUser
            }
        default:
            break
        }
    }
}

// MARK: - Table view data source
extension DashboardTableViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nearbyActivities.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityTableViewCell
        cell.NameText.text = nearbyActivities[indexPath.row][0]
        cell.AdditionalText.text = nearbyActivities[indexPath.row][1]
        // Configure the cell...
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowActivityDetail", sender: nil)
    }
}
