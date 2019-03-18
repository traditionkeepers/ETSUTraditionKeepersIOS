//
//  ActivityDetailViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class ActivityDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    var currentUser: User!
    var selectedActivity: Activity!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailCell") as! ActivityTableViewCell
            cell.NameLabel.text = selectedActivity.data["title"] as? String
            cell.SecondaryLabel.text = selectedActivity.data["category"] as? String
            cell.CompleteButton.setTitle(selectedActivity.data["date"] as? String, for: .normal)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailInstructionCell") as! InstructionsTableViewCell
            cell.InstructionText.text = selectedActivity.data["instruction"] as? String
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailMapCell") as! MapTableViewCell
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TableView.reloadData()
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.topViewController as? NewActivityTableViewController {
                vc.selectedActivity = selectedActivity
            }
        }
    }


}
