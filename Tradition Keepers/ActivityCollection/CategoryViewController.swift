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
    
    // MARK: - Outlets
    @IBOutlet weak var SortSelector: UISegmentedControl!
    @IBOutlet weak var ActivityTable: UITableView!
    
    // MARK: - Actions
    
    // MARK: - Properties
    private enum SortBy {
        case category
        case alphebetical
        case timeline
    }
    
    private var categories: [Category] = Category.Categories

    private let currentUser = User.currentUser
    var selectedCategory: String!
    private var selectedActivityIndex: IndexPath!
    private var DateFormat = DateFormatter()
    
    private var allActivities: [String:[Activity]] = [:] {
        didSet {
            for cat in completedActivities.keys {
                for act in completedActivities[cat]! {
                    if let index = allActivities[cat]!.firstIndex(of: act), index >= 0 {
                        allActivities[cat]![index] = act
                    }
                }
            }
        }
    }
    
    private var completedActivities: [String:[Activity]] = [:] {
        didSet {
            for cat in completedActivities.keys {
                for act in completedActivities[cat]! {
                    if let index = allActivities[cat]!.firstIndex(of: act), index >= 0 {
                        allActivities[cat]![index] = act
                    }
                }
            }
        }
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DateFormat.dateStyle = .short
        DateFormat.timeStyle = .none
        DateFormat.locale = Locale(identifier: "en_US")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        if currentUser.data.permission == .admin {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear Selection
        if let selectionIndexPath = ActivityTable.indexPathForSelectedRow {
            ActivityTable.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        for category in categories {
            FetchAllActivitiesForCategory(category.name)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "ShowActivityDetail":
            if let vc = segue.destination as? ActivityDetailViewController {
                vc.selectedActivity = allActivities[categories[selectedActivityIndex.section].name]![selectedActivityIndex.row]
            }
        case "NewActivity":
            if let nc = segue.destination as? UINavigationController {
                let vc = nc.topViewController as! NewActivityTableViewController
                vc.selectedActivity = Activity()
            }
        default:
            break;
        }
    }
    
}

// MARK: - Table view data source
extension CategoryViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCompletedCell", for: indexPath) as! ActivityTableViewCell
        
        cell.NameLabel.text = allActivities[categories[indexPath.section].name]![indexPath.row].activity_data["title"] as? String
        cell.SecondaryLabel.text = allActivities[categories[indexPath.section].name]![indexPath.row].activity_data["instruction"] as? String
        
        if User.permission != .user {
            cell.CompleteButton.isHidden = true
        } else {
            let status = allActivities[categories[indexPath.section].name]![indexPath.row].status
            switch status {
            case .none:
                cell.CompleteButton.setTitle(status.rawValue, for: UIControl.State.normal)
                cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU GOLD"), for: .normal)
                cell.CompleteButtonPressed = { (cell) in
                    self.ShowAlertForSelection(indexPath)
                }
            case .pending:
                cell.CompleteButton.setTitle(status.rawValue, for: UIControl.State.normal)
                cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
                cell.CompleteButtonPressed = nil
            case .verified:
                if let date = allActivities[categories[indexPath.section].name]![indexPath.row].completion_data["date"] as? Timestamp {
                    cell.CompleteButton.setTitle(DateFormat.string(from: date.dateValue()), for: .normal)
                    cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
                    cell.CompleteButtonPressed = nil
                }
            }
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section < sectionHeaders.count {
//            return sectionHeaders[section]
//        } else {
//            return ""
//        }
//    }
    
    func ShowAlertForSelection(_ indexPath: IndexPath) {
        print("Complete Button Pressed")
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            self.allActivities[self.categories[indexPath.section].name]![indexPath.row].status = .pending
            self.allActivities[self.categories[indexPath.section].name]![indexPath.row].completion_data["user_id"] = User.uid
            self.allActivities[self.categories[indexPath.section].name]![indexPath.row].completion_data["activity_ref"] = Activity.db.document("activities/\(self.allActivities[self.categories[indexPath.section].name]![indexPath.row].id ?? "")")
            self.allActivities[self.categories[indexPath.section].name]![indexPath.row].completion_data["date"] = Timestamp(date: Date())
            self.UpdateDatabase(activity: self.allActivities[self.categories[indexPath.section].name]![indexPath.row])
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedActivityIndex = indexPath
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
}

// MARK: - Firebase
extension CategoryViewController {
    
    
    /// Fetches all category information from Firestore.
    func FetchCategories() {
        var tempCategories:[Category] = []
        Activity.db.collection("categories").order(by: "title").getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                self.categories.removeAll()
                for doc in QuerySnapshot!.documents {
                    tempCategories.append(Category(fromDoc: doc))
                }
                Category.Categories = tempCategories
            }
        })
    }
    
    func FetchAllActivitiesByTitle() {
        var activities: [Activity] = []
        Activity.db.collection("activities").order(by: "title").getDocuments(completion: { (QuerySnapshot
            , err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Activity(fromDoc: doc))
                }
            }
        })
    }
    
    func FetchAllActivitiesByCategory() {
        var activities: [Activity] = []
        Activity.db.collection("activities").order(by: "category").order(by: "title").getDocuments(completion: { (QuerySnapshot
            , err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Activity(fromDoc: doc))
                }
            }
        })
    }
    
    /// Fetches the activities in the current category
    func FetchAllActivitiesForCategory(_ category: String = "General") {
        var activities: [Activity] = []
        Activity.db.collection("activities").whereField("category", isEqualTo: category).getDocuments(completion: { (QuerySnapshot
            , err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Activity(fromDoc: doc))
                }
                self.allActivities[category] = activities
            }
        })
    }
    
    
    /// Fetches the activities completd by the current user
    func FetchCompletedActivitiesForCategory(_ category: String = "General") {
        var compActivities: [Activity] = []
        Activity.db.collection("completed_activities").whereField("user_id", isEqualTo: currentUser.data.uid).getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for activity in QuerySnapshot!.documents {
                    compActivities.append(Activity(fromDoc: activity))
                }
                self.completedActivities[category] = compActivities
            }
        })
    }
    
    func UpdateDatabase(activity: Activity) {
        if activity.id != nil {
            Activity.db.collection("completed_activities").document().setData(activity.completed) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
    }
}
