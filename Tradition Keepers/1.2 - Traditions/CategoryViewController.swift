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
        observeQuery()
    }
    
    @IBAction func UnwindToActivities(unwindSegue: UIStoryboardSegue) {
        
    }
    
    let backgroundView = UIImageView()
    
    private var traditions: [Tradition] = []
    private var groups: [String:[Tradition]] = [:]
    private var documents: [DocumentSnapshot] = []
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    
    private var db: Firestore!
    private var listener: ListenerRegistration?
    
    fileprivate func observeQuery() {
        guard let query = query else { return }
        stopObserving()
        
        // Display data from Firestore, part one
        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            let models = snapshot.documents.map { (document) -> Tradition in
                if let model = Tradition(dictionary: document.data(), id: document.documentID) {
                    return model
                } else {
                    print("Unable to initialize type \(Tradition.self) with dictionary \(document.data())")
                    return Tradition()
                }
            }
            self.traditions = models
            if self.sort == .category {
                self.groups = Dictionary(grouping: models, by: { $0.category.name })
            } else {
                self.groups = Dictionary(grouping: models, by: { $0.title.first?.description ?? "" })
            }
            
            self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                self.ActivityTable.backgroundView = nil
            } else {
                self.ActivityTable.backgroundView = self.backgroundView
            }
            
            DispatchQueue.main.async {
                self.ActivityTable.reloadData()
            }
            
        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        return db.collection("traditions").limit(to: 20)
    }
    
    deinit {
        listener?.remove()
    }
    
    /// Enumertaion for the table sort order.
    ///
    /// - category: Sort table by activity category (A -> Z).
    /// - alphebetical: Sort table by activity name (A- > Z).
    /// - timeline: Sort table by order of activities.
    internal enum SortBy: String {
        case category = "category"
        case alphebetical = "title"
    }
    
    /// Enumerated value for the table sort order.
    private var sort = SortBy.category
    
    /// The currently logged in user.
    private let currentUser = User.current
    
    /// The IndexPath selected from the table.
    var selectedActivityIndex: IndexPath!
    
    /// The currently selected category for display.
    var selectedCateogy: Category!
    
    /// Formats activity date parameter for display.
    private var DateFormat = DateFormatter()
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        query = baseQuery()
        PrepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeQuery()
        
        if selectedCateogy != nil {
            self.title = selectedCateogy.name
            self.SortSelector.isHidden = true
            self.sort = .alphebetical
        } else {
            self.title = "All Traditions"
            self.SortSelector.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }
    
    func PrepareView() {
        DateFormat.dateStyle = .short
        DateFormat.timeStyle = .none
        DateFormat.locale = Locale(identifier: "en_US")
        
        // Clear Selection
        if let selectionIndexPath = ActivityTable.indexPathForSelectedRow {
            ActivityTable.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        switch User.current.permission {
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
                vc.tradition = traditions[selectedActivityIndex.row]
            }
            
        case "NewActivity":
            if let nc = segue.destination as? UINavigationController {
                let vc = nc.topViewController as! NewActivityTableViewController
                vc.selectedActivity = Tradition()
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
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let key = Array(groups.keys)[section]
        return groups[key]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedCateogy != nil {
            return ""
        } else {
            return Array(groups.keys)[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TraditionTableViewCell.cellForTableView(tableView: tableView, atIndex: indexPath)
        let key = Array(groups.keys)[indexPath.section]
        let tradition = groups[key]![indexPath.row]
        cell.prepare(tradition: tradition)
        
        cell.CompleteButtonPressed = { (cell) in
            self.ShowAlert(forTradition: tradition)
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
            let key = Array(groups.keys)[indexPath.section]
            let tradition = groups[key]![indexPath.row]
            db.collection("traditions").document(tradition.id).delete() { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
//                    self.groups[key]!.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print("Document successfully removed!")
                }
            }
         } else if editingStyle == .insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    
    func ShowAlert(forTradition tradition: Tradition) {
        print("Complete Button Pressed")
        
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            var tradition = tradition
            tradition.submission = SubmittedTradition(status: .pending,
                                                      user_id: User.current.uid,
                                                      completion_date: Date(),
                                                      activity: tradition.id)
            self.UpdateDatabase(tradition: tradition)
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        self.present(alert, animated: true, completion: nil)
    }
}

extension CategoryViewController: FiltersViewControllerDelegate {
    func query(withCategory category: String?, sortBy sort: String?) -> Query {
        var filtered = baseQuery()
        
        if let category = category, !category.isEmpty, category != "All Traditions" {
            filtered = filtered.whereField("category", isEqualTo: category)
            filtered = filtered.order(by: "title")
        } else {
            if let sort = sort, !sort.isEmpty {
                filtered = filtered.order(by: sort)
            } else {
                filtered = filtered.order(by: "title")
            }
        }
        
        
        
        return filtered
    }
    
    func controller(_ controller: CategoryTableViewController, didSelectCategory category: String?) {
        let filtered = query(withCategory: category, sortBy: self.sort.rawValue)
        
        if let category = category, !category.isEmpty {
            if category == "All Traditions" {
                SortSelector.isHidden = false
            } else {
                SortSelector.isHidden = true
            }
            self.title = category
        }
        
        self.query = filtered
        observeQuery()
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
//
//    /// Fetches all category information from Firestore.
//    func FetchCategories() {
//        var tempCategories:[String:Category] = [:]
//        Activity.db.collection("categories").order(by: "title").getDocuments(completion: { (QuerySnapshot, err) in
//            if let err = err {
//                print("Error retreiving documents: \(err)")
//            } else {
//                self.categories.removeAll()
//                for doc in QuerySnapshot!.documents {
//                    let new = Category(fromDoc: doc)
//                    tempCategories[new.name] = new
//                }
//                Category.Categories = tempCategories
//            }
//        })
//    }
//
//
//    /// Fetches all activities, grouped by first title character.
//    func FetchAllActivitiesByTitle() {
//        var activities: [Activity] = []
//        Activity.db.collection("activities").order(by: "title").getDocuments(completion: { (QuerySnapshot, err) in
//            if let err = err {
//                print("Error retreiving documents: \(err)")
//            } else {
//                for doc in QuerySnapshot!.documents {
//                    activities.append(Activity(fromDoc: doc))
//                }
//                self.AllActivities = Dictionary(grouping: activities, by: { $0.title.first?.description ?? "" })
//            }
//        })
//    }
//
//
//    /// Fetches all activities, grouped by category.
//    func FetchAllActivitiesByCategory() {
//        var activities: [Activity] = []
//        Activity.db.collection("activities").order(by: "category").getDocuments(completion: { (QuerySnapshot
//            , err) in
//            if let err = err {
//                print("Error retreiving documents: \(err)")
//            } else {
//                for doc in QuerySnapshot!.documents {
//                    activities.append(Activity(fromDoc: doc))
//                }
//                activities.sort(by: {
//                    if $0.category == $1.category {
//                        return $0.title < $1.title
//                    } else {
//                        return $0.category < $1.category
//                    }
//                })
//                self.AllActivities = Dictionary(grouping: activities, by: { $0.category })
//            }
//        })
//    }
//
//
//    /// Fetches all activities in the specified category.
//    ///
//    /// - Parameter category: The desired category to fetch
//    func FetchAllActivitiesForCategory(_ category: String = "General") {
//        var activities: [Activity] = []
//        Activity.db.collection("activities").whereField("category", isEqualTo: category).getDocuments(completion: { (QuerySnapshot, err) in
//            if let err = err {
//                print("Error retreiving documents: \(err)")
//            } else {
//                for doc in QuerySnapshot!.documents {
//                    activities.append(Activity(fromDoc: doc))
//                }
//                self.AllActivities = [category: activities]
//            }
//        })
//    }
//
//
//    /// Fetches all activities completed by the user
//    func FetchCompletedActivities() {
//        var compActivities: [Activity] = []
//        Activity.db.collection("completed_activities").whereField("user_id", isEqualTo: currentUser.uid).getDocuments(completion: { (QuerySnapshot, err) in
//            if let err = err {
//                print("Error retreiving documents: \(err)")
//            } else {
//                for activity in QuerySnapshot!.documents {
//                    compActivities.append(Activity(fromDoc: activity))
//                }
//                self.completedActivities = compActivities
//            }
//        })
//    }
//
//
    /// Updates the database with a new completed activity.
    ///
    /// - Parameter activity: The activity object to upload.
    func UpdateDatabase(tradition: Tradition) {
        if tradition.id != "" {
            db.collection("submissions").document().setData(tradition.submissionDictionary) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
    }
}
