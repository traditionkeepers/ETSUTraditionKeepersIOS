//
//  TableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sectionHeaders = [
        "General Activities",
        "Extra Activities"
    ]
    
    var selectedCategory: String!
    var allActivities: [Activity] = [] {
        didSet {
            ActivityTable.reloadData()
        }
    }
    
    private var selectedActivityIndex: Int!
    
    var currentUser: User!
    var completedActivities: [Activity] = []
    
    @IBOutlet weak var CategoryNameLabel: UILabel!
    @IBOutlet weak var ProgressLabel: UILabel!
    @IBOutlet weak var ActivityTable: UITableView!
    @IBOutlet weak var AddActivityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CategoryNameLabel.text = selectedCategory
        ProgressLabel.text = "Progress: \(currentUser.data.uid)%"
        FetchData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        if currentUser.data.permission == .admin {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
    }
    
    // MARK: - Firebase
    func FetchData() {
        Activity.db.collection("activities").whereField("category", isEqualTo: selectedCategory).getDocuments(completion: { (QuerySnapshot
            , err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                self.allActivities.removeAll()
                for doc in QuerySnapshot!.documents {
                    self.allActivities.append(Activity(fromDoc: doc))
                }
            }
        })
    }
    
    func CompletedActivities() {
        Activity.db.collection("completed_activities").whereField("uid", isEqualTo: currentUser.data.uid).getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for activity in QuerySnapshot!.documents {
                    self.completedActivities.append(Activity(fromDoc: activity))
                }
            }
        })
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return allActivities.count
        } else if section == 1 {
            return allActivities.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCompletedCell", for: indexPath) as! ActivityTableViewCell
        cell.NameText.text = allActivities[indexPath.row].data.name
        cell.AdditionalText.text = allActivities[indexPath.row].data.instruction
        cell.CompleteButton.setTitle(allActivities[indexPath.row].status.rawValue, for: UIControl.State.normal)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowActivityDetail", sender: nil)
    }
    
     // Override to support conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
     }

    
     // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
     }

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
        switch segue.identifier {
        case "ShowActivityDetail":
            if let vc = segue.destination as? ActivityDetailViewController {
                vc.currentUser = self.currentUser
                vc.selectedActivity = allActivities[selectedActivityIndex]
            }
        case "NewActivity":
            if let nc = segue.destination as? UINavigationController {
                let vc = nc.topViewController as! ActivityDetailViewController
                vc.currentUser = self.currentUser
                vc.selectedActivity = Activity()
            }
        default:
            break;
        }
    }
    
}
