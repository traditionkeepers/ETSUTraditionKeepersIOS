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
    
    /// background to show when no data is found.
    let backgroundView = UIImageView()
    private var categories: [Category] = []
    private var documents: [DocumentSnapshot] = []
    
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
                if let model = Category(dictionary: document.data()) {
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
        return Firestore.firestore().collection("restaurants").limit(to: 50)
    }
    
//    lazy private var filters: (navigationController: UINavigationController,
//        filtersController: FiltersViewController) = {
//            return FiltersViewController.fromStoryboard(delegate: self)
//    }()
    
    
    // MARK: - Properties
    var submitted = Category(name: "All Traditions", count: 0)
    
    private var sectionHeader:[String] = [
        "",
        ""
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
        switch User.current.permission {
        case .user:
            if indexPath.section == 0 {
                cell.Title.text = submitted.name
                cell.Detail.text = submitted.count.description
            } else {
                cell.Title.text = categories[cateogryTitles[indexPath.row]]?.name
                cell.Detail.text = categories[cateogryTitles[indexPath.row]]?.count.description
            }
        default:
            cell.Title.text = categories[cateogryTitles[indexPath.row]]?.name
            cell.Detail.text = categories[cateogryTitles[indexPath.row]]?.count.description
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath
        DismissView()
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        if segue.identifier == "UnwindToActivities" {
            if let vc = segue.destination as? CategoryViewController {
                switch User.permission {
                case .user:
                    if let ip = selectedCategoryIndex {
                        if selectedCategoryIndex.section == 0 {
                            vc.selectedCateogy = nil
                        } else {
                            let category = cateogryTitles[ip.row]
                            vc.selectedCateogy = categories[category]
                        }
                    }
                default:
                    if let ip = selectedCategoryIndex {
                        let category = cateogryTitles[ip.row]
                        vc.selectedCateogy = categories[category]
                    }
                }
                
            }
        }
    }

}
