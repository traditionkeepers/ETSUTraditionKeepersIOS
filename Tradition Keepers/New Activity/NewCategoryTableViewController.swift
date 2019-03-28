
//
//  CategoryTableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/17/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class NewCategoryTableViewController: UITableViewController {
    
    var categories: [Category] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedCategory: Category?
    
    @IBAction func AddNewCategory(_ sender: Any) {
        let alert = UIAlertController(title: "New Category", message: "Enter the name of the new category.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (nil) in
            
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (nil) in
            if let text = alert.textFields?[0].text {
                if text.count > 0 {
                    self.categories.append(Category(withName: text))
                    self.categories.sort()
                    self.tableView.reloadData()
                }
            }
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Title"
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FetchCategories()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        cell.Title.text = categories[indexPath.row].name
        cell.Detail.text = categories[indexPath.row].count.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        Activity.categories = categories
        performSegue(withIdentifier: "unwindToNewActivity", sender: nil)
    }
}

// MARK: - Firebase
extension NewCategoryTableViewController {
    func FetchCategories() {
        var temp_categories: [Category] = []
        Activity.db.collection("categories").getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    temp_categories.append(Category(fromDoc: doc))
                }
                self.categories = temp_categories
            }
        })
    }
}
