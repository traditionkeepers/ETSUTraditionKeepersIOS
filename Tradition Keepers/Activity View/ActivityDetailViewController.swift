//
//  ActivityDetailViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class ActivityDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    
    private let currentUser = User.currentUser
    var selectedActivity: Activity!
    private var DateFormat = DateFormatter()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailCell") as! ActivityTableViewCell
            cell.NameLabel.text = selectedActivity.title
            cell.SecondaryLabel.text = selectedActivity.category
            let status = selectedActivity.completion.status
            switch status {
            case .none:
                cell.CompleteButton.setTitle(status.rawValue, for: UIControl.State.normal)
                cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU GOLD"), for: .normal)
                cell.CompleteButtonPressed = { (cell) in
                    self.ShowAlertForRow(row: indexPath.row)
                }
            case .pending:
                cell.CompleteButton.setTitle(status.rawValue, for: UIControl.State.normal)
                cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
                cell.CompleteButtonPressed = nil
            case .verified:
                let date = selectedActivity.completion.date
                cell.CompleteButton.setTitle(DateFormat.string(from: date), for: .normal)
                cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
                cell.CompleteButtonPressed = nil
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailInstructionCell") as! InstructionsTableViewCell
            cell.InstructionText.text = selectedActivity.instruction
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailMapCell") as! MapTableViewCell
            
            // Set Activity Pin Before configuring...
            cell.MapPin = ActivityPin(title: selectedActivity.title,
                                      locationName: selectedActivity.location.name,
                                      coordinate: selectedActivity.location.coordinate.coordinate)
            
            cell.Configure()
            
            
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DateFormat.dateStyle = .short
        DateFormat.timeStyle = .none
        DateFormat.locale = Locale(identifier: "en_US")

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PrepareView()
        TableView.reloadData()
        
    }
    
    func PrepareView() {
        switch User.permission {
        case .staff, .admin:
            print("Admin mode")
        default:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func ShowAlertForRow(row: Int) {
        print("Complete Button Pressed")
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            self.selectedActivity.completion.status = .pending
            self.selectedActivity.completion.user_id = User.uid
            self.selectedActivity.completion.activity_ref = Activity.db.document("activities/\(self.selectedActivity.id ?? "")")
            self.selectedActivity.completion.date = Date()
            self.UpdateDatabase(activity: self.selectedActivity)
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func UpdateDatabase(activity: Activity) {
        if activity.id != nil {
            Activity.db.collection("completed_activities").document().setData(activity.Completed) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
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

// MARK: - MapKit
extension ActivityDetailViewController {
    
}
