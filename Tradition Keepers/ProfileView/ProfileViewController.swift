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
    
    var db: Firestore!
    var userInfo: DocumentSnapshot!
    
    var sectionHeaders = [
        "General Activities",
        "Extra Activities"
    ]
    
    var completedActivities = [
        ["Event 1", "Event 1 Description", "12/12/12"],
        ["Event 2", "Event 2 Description", "11/11/11"],
        ["Event 3", "Event 3 Description", "10/10/10"]
    ]
    
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var ProgressLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        UserNameLabel.text = "\(userInfo.get("first") as? String ?? "") \(userInfo.get("last") as? String ?? "")"
        ProgressLabel.text = "Progress: \(Auth.auth().currentUser?.uid ?? "XXX")%"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return completedActivities.count
        } else if section == 1 {
            return completedActivities.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompleteActivityCell", for: indexPath) as! ActivityTableViewCell
        cell.NameLabel.text = completedActivities[indexPath.row][0]
        cell.DescriptionLabel.text = completedActivities[indexPath.row][1]
        cell.CompleteButton.setTitle(completedActivities[indexPath.row][2], for: UIControl.State.normal)
        cell.CompleteButton.isEnabled = false
        // Configure the cell...
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sectionHeaders.count {
            return sectionHeaders[section]
        } else {
            return ""
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
    
}
