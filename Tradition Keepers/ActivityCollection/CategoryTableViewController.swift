//
//  CategoryTableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/28/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class CategoryTableViewController: UITableViewController {
    
    // MARK: - Properties
    var categories:[Category] = Category.Categories
    var submitted = Category(withName: "Submissions")
    
    private var sectionHeader:[String] = [
        "",
        "All Categories"
    ]
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categories = Category.Categories
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        switch User.permission {
        case .user:
            return sectionHeader.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch User.permission {
        case .user:
            if section == 0 {
                return 1
            } else {
                return categories.count
            }
        default:
            return categories.count
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        switch User.permission {
        case .user:
            if indexPath.section == 0 {
                cell.Title.text = submitted.name
                cell.Title.text = submitted.count.description
            } else {
                cell.Title.text = categories[indexPath.row].name
                cell.Detail.text = categories[indexPath.row].count.description
            }
        default:
            cell.Title.text = categories[indexPath.row].name
            cell.Detail.text = categories[indexPath.row].count.description
        }

        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
