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
                if selectedCateogy == nil {
                    FetchAllActivitiesByTitle()
                } else {
                    FetchAllActivitiesForCategory(selectedCateogy.name)
                }
            case .category:
                categories = Category.Categories
            }
        }
    }
    
    private var categories = Category.Categories {
        didSet {
            FetchAllActivitiesByCategory()
        }
    }
    
    private var FilteredTitles: [String] {
        return FilteredData.keys.sorted()
    }
    private var FilteredData: [String:[Activity]] = [:] {
        didSet {
            ActivityTable.reloadData()
        }
    }
    
    private var AllActivities: [String:[Activity]] = [:] {
        didSet
        {
            FilteredData = AllActivities
            print(AllActivities)
        }
    }
    
    
    /// The currently logged in user.
    private let currentUser = User.currentUser
    
    /// The IndexPath selected from the table.
    var selectedActivityIndex: IndexPath!
    
    /// The currently selected category for display.
    var selectedCateogy: Category!
    
    /// Formats activity date parameter for display.
    private var DateFormat = DateFormatter()
    
    /// Dictionary of user completed activities fetched from server.
    private var completedActivities: [Activity] = [] {
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
            
        case .staff, .admin:
            print("Admin mode")
            if !(self.navigationItem.rightBarButtonItems?.contains(self.editButtonItem) ?? true) {
                self.navigationItem.rightBarButtonItems?.insert(self.editButtonItem, at: 0)
            }
            navigationItem.leftBarButtonItem = nil
        }
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        if selectedCateogy != nil {
            self.title = selectedCateogy.name
            self.SortSelector.isHidden = true
            self.sort = .alphebetical
        } else {
            self.title = "All Traditions"
            self.SortSelector.isHidden = false
            Category.onUpdate = { categories in
                self.categories = categories
            }
            FetchCategories()
        }
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
                if let data = FilteredData[FilteredTitles[selectedActivityIndex.section]] {
                    vc.selectedActivity = data[selectedActivityIndex.row]
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
        return FilteredTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let key = FilteredTitles[section]
        return FilteredData[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedCateogy != nil {
            return ""
        } else {
            return FilteredTitles[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityTableViewCell
        
        let key = FilteredTitles[indexPath.section]
        
        guard let activity = FilteredData[key]?[indexPath.row] else {
            return cell
        }
        
        cell.NameLabel.text = activity.title
        cell.SecondaryLabel.text = activity.instruction
        
        if User.permission != .user {
            cell.CompleteButton.isHidden = true
        } else {
            let status = activity.completion.status
            
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
                cell.CompleteButton.setTitle(DateFormat.string(from: activity.completion.date), for: .normal)
                cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
                cell.CompleteButtonPressed = nil
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
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let photoPicker = UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.sourceType = .camera
            
            self.present(photoPicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            }
            let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
                let activity = self.FilteredData[self.FilteredTitles[indexPath.section]]![indexPath.row]
                activity.completion.status = .pending
                activity.completion.user_id = User.uid
                activity.completion.activity_ref = Activity.db.document("activities/\(String(describing: activity.id))")
                activity.completion.date = Date()
                self.UpdateDatabase(activity: activity)
            }
            
            alert.addAction(cancel)
            alert.addAction(submit)
            self.present(alert, animated: true, completion: nil)
        }
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

extension CategoryViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
    
    
    /// Fetches all activities, grouped by first title character.
    func FetchAllActivitiesByTitle() {
        var activities: [Activity] = []
        Activity.db.collection("activities").order(by: "title").getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Activity(fromDoc: doc))
                }
                self.AllActivities = Dictionary(grouping: activities, by: { $0.title.first?.description ?? "" })
            }
        })
    }
    
    
    /// Fetches all activities, grouped by category.
    func FetchAllActivitiesByCategory() {
        var activities: [Activity] = []
        Activity.db.collection("activities").order(by: "category").getDocuments(completion: { (QuerySnapshot
            , err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Activity(fromDoc: doc))
                }
                activities.sort(by: {
                    if $0.category == $1.category {
                        return $0.title < $1.title
                    } else {
                        return $0.category < $1.category
                    }
                })
                self.AllActivities = Dictionary(grouping: activities, by: { $0.category })
            }
        })
    }
    
    
    /// Fetches all activities in the specified category.
    ///
    /// - Parameter category: The desired category to fetch
    func FetchAllActivitiesForCategory(_ category: String = "General") {
        var activities: [Activity] = []
        Activity.db.collection("activities").whereField("category", isEqualTo: category).getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Activity(fromDoc: doc))
                }
                self.AllActivities = [category: activities]
            }
        })
    }
    
    
    /// Fetches all activities completed by the user
    func FetchCompletedActivities() {
        var compActivities: [Activity] = []
        Activity.db.collection("completed_activities").whereField("user_id", isEqualTo: currentUser.uid).getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for activity in QuerySnapshot!.documents {
                    compActivities.append(Activity(fromDoc: activity))
                }
                self.completedActivities = compActivities
            }
        })
    }
    
    
    /// Updates the database with a new completed activity.
    ///
    /// - Parameter activity: The activity object to upload.
    func UpdateDatabase(activity: Activity) {
        if activity.id != "" {
            Activity.db.collection("completed_activities").document().setData(activity.Completed) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
    }
}
