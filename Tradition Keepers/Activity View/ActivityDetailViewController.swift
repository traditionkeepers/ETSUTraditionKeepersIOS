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
    
    var currentUser: User!
    var selectedActivity: Activity!
    
    var eventInfo:[String:String] = ["name":"Event 1", "category":"Event 1 Cat", "instructions":"Event 1 Instructions", "loc":"Event 1 Location Name", "completion":"12/12/12"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailCell") as! ActivityTableViewCell
            cell.NameText.text = eventInfo["name"]
            cell.AdditionalText.text = eventInfo["category"]
            cell.CompleteButton.setTitle(eventInfo["completion"], for: .normal)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailInstructionCell") as! InstructionsTableViewCell
            cell.InstructionText.text = eventInfo["instructions"]
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
