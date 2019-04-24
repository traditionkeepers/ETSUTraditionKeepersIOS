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
    /// Enumertaion for the table sort order.
    ///
    /// - category: Sort table by activity category (A -> Z).
    /// - alphebetical: Sort table by activity name (A- > Z).
    /// - timeline: Sort table by order of activities.
    internal enum SortBy: String {
        case requirement = "category"
        case alphebetical = "title"
    }
    
    /// Enumerated value for the table sort order.
    private var sort = SortBy.requirement
    
    /// The currently logged in user.
    private let currentUser = User.current
    
    /// The IndexPath selected from the table.
    private var selectedTradition: Tradition!
    
    /// The currently selected category for display.
    var selectedCategory: Category! {
        didSet {
            if selectedCategory.id != "all" {
                self.SortButton.isEnabled = false
                query = baseQuery().whereField("requirement", isEqualTo: selectedCategory.id)
                self.sort = .alphebetical
            } else {
                self.SortButton.isEnabled = true
                query = baseQuery()
            }
        }
    }
    
    /// Formats activity date parameter for display.
    private var DateFormat = DateFormatter()
    
    let backgroundView = UIImageView()

    private var traditions: [Tradition] = []
    private var groups: [String:[Tradition]] = [:]
    private var documents: [DocumentSnapshot] = []
    
    // MARK: - Outlets
    @IBOutlet var BackButton: UIBarButtonItem!
    @IBOutlet weak var ActivityTable: UITableView!
    @IBOutlet weak var SortButton: UIBarButtonItem!
    
    var FilterTitleButton: UIButton {
        let fb = UIButton(type: .custom)
        fb.addTarget(self, action: #selector(FilterButtonPressed(_:)), for: .touchUpInside)
//        fb.setIcon(prefixText: "All Traditions", icon: .linearIcons(.arrowDown), postfixText: "", forState: .normal)
        fb.setIcon(prefixText: self.selectedCategory.name, prefixTextColor: .white, icon: .linearIcons(.arrowDown), iconColor: .white, postfixText: "", postfixTextColor: .white, backgroundColor: .clear, forState: .normal, textSize: nil, iconSize: nil)
        return fb
    }
    
    // MARK: - Actions
    @IBAction func BackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func FilterButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Filter", sender: sender)
    }
    
    @IBAction func SortButtonPresses(_ sender: Any) {
        let alert = UIAlertController(title: "Sort By", message: "Choose a parameter to sort by.", preferredStyle: .actionSheet)
        let alphabbetical = UIAlertAction(title: "Title", style: .default) { (_) in
            self.sort = .alphebetical
            self.observeQuery()
        }
        
        let requirement = UIAlertAction(title: "Requirement", style: .default) { (_) in
            self.sort = .requirement
            self.observeQuery()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(requirement)
        alert.addAction(alphabbetical)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @IBAction func UnwindToActivities(unwindSegue: UIStoryboardSegue) { }
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    
    private var db: Firestore {
        return Firestore.firestore()
    }
    
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
            if self.sort == .requirement {
                self.groups = Dictionary(grouping: models, by: { $0.requirement.id })
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
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        query = baseQuery()
        PrepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeQuery()
        
        self.navigationItem.titleView = FilterTitleButton
        self.setEditing(false, animated: true)
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
        
        SortButton.setIcon(icon: .linearIcons(.sortAlphaAsc), iconSize: 20, color: .white)
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
        
        selectedCategory = Category(id: "all", name: "All Traditions", count: 0)
        
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
                vc.tradition = selectedTradition
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
        let key = sort == .alphebetical ? Array(groups.keys).sorted()[section] : Array(groups.keys).sorted().reversed()[section]
        return groups[key]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedCategory.id != "all" {
            return ""
        } else {
            return sort == .alphebetical ? Array(groups.keys).sorted()[section] : Array(groups.keys).sorted().reversed()[section]
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView?.backgroundColor = .clear
        header.textLabel?.textColor = .white
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = sort == .alphebetical ? Array(groups.keys).sorted()[indexPath
            .section] : Array(groups.keys).sorted().reversed()[indexPath.section]
        let tradition = groups[key]![indexPath.row]
        let cell = TraditionTableViewCell.cellForTableView(tableView: tableView, atIndex: indexPath, tradition: tradition)
        
        cell.CompleteButtonPressed = { (sender) in
            
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
            
            let key = Array(groups.keys)[indexPath.section]
            let tradition = groups[key]![indexPath.row]
            let batch = db.batch()
            
            let traditionRef = db.collection("traditions").document(tradition.id)
            batch.deleteDocument(traditionRef)
            
            let countRef = db.collection("requirement").document(tradition.requirement.id)
            batch.updateData(["count": FieldValue.increment(Int64(-1))], forDocument: countRef)
            
            batch.commit { (error) in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    //                    self.groups[key]!.remove(at: indexPath.row)
                    print("Document successfully removed!")
                }
            }
         } else if editingStyle == .insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
     }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = sort == .alphebetical ? Array(groups.keys).sorted()[indexPath.section] : Array(groups.keys).sorted().reversed()[indexPath.section]
        selectedTradition = groups[key]![indexPath.row]
        performSegue(withIdentifier: "ShowActivityDetail", sender: nil)
    }
}

extension CategoryViewController: FiltersViewControllerDelegate {
    func query(withRequirement requirement: String?, sortBy sort: String?) -> Query {
        var filtered = baseQuery()
        
        if let requirement = requirement, !requirement.isEmpty, requirement != "All Traditions" {
            filtered = filtered.whereField("requirement", isEqualTo: requirement)
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
    
    func controller(_ controller: CategoryTableViewController, didSelectFilter filter: String?) {
        let filtered = query(withRequirement: filter, sortBy: self.sort.rawValue)
        
        if let filter = filter, !filter.isEmpty {
            if filter == "All Traditions" {
                SortButton.isEnabled = false
            } else {
                SortButton.isEnabled = true
            }
            self.title = filter
        }
        
        self.query = filtered
        observeQuery()
    }
}
