//
//  UsersTableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/3/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class UsersTableViewController: UIViewController {
    
    private var filteredUsers: [User] = []
    private var allUsers: [User] = [] {
        didSet {
            filteredUsers = allUsers
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FetchUsers()
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

// MARK: - Table View
extension UsersTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = filteredUsers[indexPath.row]
    }
}

// MARK: - Firebase
extension UsersTableViewController {
    func FetchUsers() {
        print("Fetching User Data")
        var foundUsers: [User] = []
        let docref = User.db.collection("users")
        docref.getDocuments { (QuerySnapshot, error) in
            if let error = error {
                print("Error fetching user doc! \(String(describing: error))")
            } else {
                for doc in QuerySnapshot!.documents {
                    let currentUser = User(fromDoc: doc)
                    foundUsers.append(currentUser)
                }
            }
        }
    }
}
