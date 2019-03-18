//
//  TableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var completedActivities: [Activity] = [] {
        didSet {
            TableView.reloadData()
        }
    }
    var currentUser: User!
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var ProgressLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GetUserActivities()
        UserNameLabel.text = "\(currentUser.data.first) \(currentUser.data.last)"
        ProgressLabel.text = "Progress: \(currentUser.data.uid)%"
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return completedActivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCompletedCell", for: indexPath) as! ActivityTableViewCell
        cell.NameLabel.text = completedActivities[indexPath.row].data["title"] as? String
        cell.SecondaryLabel.text = completedActivities[indexPath.row].data["instruction"] as? String
        cell.CompleteButton.setTitle(completedActivities[indexPath.row].data["date"] as? String, for: UIControl.State.normal)
        cell.CompleteButton.isEnabled = false
        // Configure the cell...
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowActivityDetail", sender: nil)
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
        
        default:
            break;
        }
    }
    
}

// MARK: Firebase
extension ProfileViewController {
    func GetUserActivities() {
        var compActivities : [Activity] = []
        let docref = Activity.db.collection("completed_activities").whereField("user_id", isEqualTo: currentUser.data.uid).order(by: "date", descending: true)
        docref.getDocuments(completion: { (QuerySnapshot, error) in
            if let error = error {
                print("Error retreiving documents: \(error.localizedDescription)")
            } else {
                for doc in QuerySnapshot!.documents {
                    compActivities.append(Activity(fromDoc: doc))
                }
                self.completedActivities = compActivities
            }
        })
    }
}
