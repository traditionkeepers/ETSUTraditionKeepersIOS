//
//  CategoryTableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/28/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class CategoryTableViewController: UITableViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    
    /// background to show when no data is found.
    let backgroundView = UIImageView()
    private var categories: [Category] = []
    private var documents: [DocumentSnapshot] = []
    private var selectedCategory: Category? {
        didSet {
            print(selectedCategory?.id)
        }
    }
    
    private var allCategory: Category {
        var total = 0
        for cat in categories {
            total += cat.count
        }
        return Category(id: "all", name: "All Categories", count: total)
    }
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
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
            let models = snapshot.documents.map { (document) -> Category in
                if let model = Category(dictionary: document.data(), id: document.documentID) {
                    return model
                } else {
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(Category.self) with dictionary \(document.data())")
                }
            }
            self.categories = models
            self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                self.tableView.backgroundView = nil
            } else {
                self.tableView.backgroundView = self.backgroundView
            }
            
            self.tableView.reloadData()
        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("requirement")
    }
    
//    lazy private var filters: (navigationController: UINavigationController,
//        filtersController: FiltersViewController) = {
//            return FiltersViewController.fromStoryboard(delegate: self)
//    }()
    
    
    // MARK: - Properties
    private var sectionHeader:[String] = [
        "",
        "Requirement"
    ]
    
    @IBAction func DonePressed(_ sender: Any) {
        DismissView()
    }
    
    // MARK: - Functions
    func DismissView() {
        performSegue(withIdentifier: "UnwindToActivities", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query = baseQuery()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionHeader.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else {
            return categories.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeader[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        if indexPath.section == 0 {
            cell.Title.text = allCategory.name
            cell.Detail.text = allCategory.count.description
        } else {
            cell.Title.text = categories[indexPath.row].name
            cell.Detail.text = categories[indexPath.row].count.description
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedCategory = allCategory
            print(selectedCategory?.id)
        } else {
            selectedCategory = categories[indexPath.row]
            print(selectedCategory?.id, selectedCategory?.name)
        }
        DismissView()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? CategoryViewController {
            if let category = selectedCategory {
                vc.selectedCategory = category
            }
        }
    }
}

protocol FiltersViewControllerDelegate: NSObjectProtocol {
    func controller(_ controller: CategoryTableViewController, didSelectFilter filter: String?)
}
