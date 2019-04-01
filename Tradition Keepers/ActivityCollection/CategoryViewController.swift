//
//  TableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase



/// View Controller for managing the display of Activities in the specified category
class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet var BackButton: UIBarButtonItem!
    @IBOutlet weak var SortSelector: UISegmentedControl!
    @IBOutlet weak var ActivityTable: UITableView!
    
    // MARK: - Actions
    @IBAction func BackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SortByChanged(_ sender: Any) {
        if SortSelector.selectedSegmentIndex == 0 {
            sort = .category
        } else if SortSelector.selectedSegmentIndex == 1 {
            sort = .alphebetical
        }
        
        ActivityTable.reloadData()
    }
    
    @IBAction func UnwindToActivities(unwindSegue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Properties
    
    /// Enumertaion for the table sort order.
    ///
    /// - category: Sort table by activity category (A -> Z).
    /// - alphebetical: Sort table by activity name (A- > Z).
    /// - timeline: Sort table by order of activities.
    private enum SortBy {
        case category
        case alphebetical
    }
    
    /// Enumerated value for the table sort order.
    private var sort = SortBy.category {
        didSet {
            switch sort {
            case .alphebetical:
                FetchAllActivitiesByTitle()
            case .category:
                categories = Category.Categories
            }
        }
    }
    
    private var categories = Category.Categories {
        didSet {
            for category in categories.keys {
                self.FetchAllActivitiesForCategory(category)
            }
        }
    }
    
    private var FilteredTitles: [String] {
        return FilteredData.keys.sorted()
    }
    private var FilteredData: [String:[Activity]]
    
    private var AllActivities: [String:[Activity]]
    
    /// The currently logged in user.
    private let currentUser = User.currentUser
    
    /// The IndexPath selected from the table.
    var selectedActivityIndex: IndexPath!
    
    /// The currently selected category for display.
    var selectedCateogy: Category!
    
    /// Formats activity date parameter for display.
    private var DateFormat = DateFormatter()
    
    /// Dictionary of user completed activities fetched from server.
    private var completedActivities: [String:[Activity]] = [:] {
        didSet {
            ActivityTable.reloadData()
        }
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DateFormat.dateStyle = .short
        DateFormat.timeStyle = .none
        DateFormat.locale = Locale(identifier: "en_US")
        
        if User.permission == .admin || User.permission == .staff {
            print("Admin mode")
            self.navigationItem.rightBarButtonItems?.insert(self.editButtonItem, at: 0)
        }
        self.navigationController?.setToolbarHidden(true, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PrepareView()
    }
    
    func PrepareView() {
        // Clear Selection
        if let selectionIndexPath = ActivityTable.indexPathForSelectedRow {
            ActivityTable.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        switch User.permission {
        case .none:
            navigationItem.leftBarButtonItem = self.BackButton
        case .user:
            navigationItem.leftBarButtonItem = nil
        default:
            navigationItem.leftBarButtonItem = nil
        }
        
        if selectedCateogy != nil {
            self.title = selectedCateogy.name
        } else {
            self.title = "All Traditions"
        }
        
        Category.onUpdate = { categories in
            self.categories = categories
        }
        
        FetchCategories()
    }
    
    @IBAction func backAction() -> Void {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "ShowActivityDetail":
            if let vc = segue.destination as? ActivityDetailViewController {
                if selectedCateogy != nil {
                    let category = selectedCateogy.name
                    vc.selectedActivity = allActivities[category]![selectedActivityIndex.row]
                } else {
                    let category = categoryTitles[selectedActivityIndex.section]
                    vc.selectedActivity = allActivities[category]![selectedActivityIndex.row]
                }
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
        switch sort {
        case .category:
            if selectedCateogy != nil {
                return 1
            } else {
                return categories.count
            }
        default:
            if selectedCateogy != nil {
                return 1
            } else {
                return activityStartingLetters.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch sort {
        case .category:
            if selectedCateogy != nil {
                let section = selectedCateogy.name
                return categories[section]?.count ?? 0
            } else {
                let section = categoryTitles[section]
                return categories[section]?.count ?? 0
            }
            
        default:
            let char = activityStartingLetters[section]
            return activityLetterCounts[char] ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sort {
        case .category:
            if selectedCateogy != nil {
                return selectedCateogy.name
            } else {
                if categories.count > section {
                    let category = categoryTitles[section]
                    return category
                } else {
                    return "None"
                }
            }
            
        default:
            return "\(activityStartingLetters[section])"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityTableViewCell
        
        var cat: String!
        var activity: Activity!
        
        switch sort {
        case .category:
            if selectedCateogy != nil {
                cat = selectedCateogy.name
            } else {
                cat = categoryTitles[indexPath.section]
            }
            
            activity = allActivities[cat]![indexPath.row]
            if completedActivities[cat]?.contains(activity) ?? false {
                activity = completedActivities[cat]![indexPath.row]
            } else {
                activity = allActivities[cat]![indexPath.row]
            }
            
        case .alphebetical:
            if selectedCateogy != nil {
                cat = selectedCateogy.name
                activity = allActivities[cat]![indexPath.row]
                if completedActivities[cat]?.contains(activity) ?? false {
                    activity = completedActivities[cat]![indexPath.row]
                } else {
                    activity = allActivities[cat]![indexPath.row]
                }
            } else {
                let letter = activityStartingLetters[indexPath.section]
                var index = 0
                for l in activityStartingLetters {
                    let value = activityLetterCounts[l] ?? 0
                    if l == letter {
                        index += indexPath.row
                        break
                    } else {
                        index += value
                    }
                }
                activity = activityArray[index]
            }
            
            
        default:
            activity = activityArray[indexPath.row]
        }
        
        cell.NameLabel.text = activity.activity_data["title"] as? String
        cell.SecondaryLabel.text = activity.activity_data["instruction"] as? String
        
        if User.permission != .user {
            cell.CompleteButton.isHidden = true
        } else {
            let status = activity.status
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
                if let date = activity.completion_data["date"] as? Timestamp {
                    cell.CompleteButton.setTitle(DateFormat.string(from: date.dateValue()), for: .normal)
                    cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
                    cell.CompleteButtonPressed = nil
                }
            }
        }
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        ActivityTable.setEditing(editing, animated: animated)
        self.navigationController?.setToolbarHidden(!editing, animated: true)
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
    
    func ShowAlertForSelection(_ indexPath: IndexPath) {
        print("Complete Button Pressed")
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            let activity = self.allActivities[self.categoryTitles[indexPath.section]]![indexPath.row]
            activity.status = .pending
            activity.completion_data["user_id"] = User.uid
            activity.completion_data["activity_ref"] = Activity.db.document("activities/\(activity.id ?? "")")
            activity.completion_data["date"] = Timestamp(date: Date())
            self.UpdateDatabase(activity: activity)
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
}

// MARK: - Firebase
extension CategoryViewController {
    
    /// Fetches all category information from Firestore.
    func FetchCategories() {
        var tempCategories:[String:Category] = [:]
        Activity.db.collection("categories").order(by: "title").getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                self.categories.removeAll()
                for doc in QuerySnapshot!.documents {
                    let new = Category(fromDoc: doc)
                    tempCategories[new.name] = new
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
                Category.Categories[category]?.count = activities.count
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
