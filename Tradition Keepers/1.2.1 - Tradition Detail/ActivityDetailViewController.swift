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
    private var DateFormat = DateFormatter()
    
    var tradition: Tradition!
    var document: DocumentSnapshot!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = TraditionTableViewCell.cellForTableView(tableView: tableView, atIndex: indexPath)
            cell.tradition = tradition
            cell.NameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailInstructionCell") as! InstructionsTableViewCell
            cell.InstructionText.text = tradition.instruction
            cell.InstructionText.font = UIFont.preferredFont(forTextStyle: .subheadline)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityDetailMapCell") as! MapTableViewCell
            // Set Activity Pin Before configuring...
            cell.MapPin = ActivityPin(title: tradition.title,
                                      locationName: tradition.location.title,
                                      coordinate: tradition.location.coordinate.coordinate)
            
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
        switch User.current.permission {
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
            self.tradition.submission = SubmittedTradition(status: .pending,
                                                             user: User.current.name_FL,
                                                             completion_date: Date(),
                                                             tradition: self.tradition.id,
                                                             location: nil,
                                                             image: nil)
            self.UpdateDatabase(activity: self.tradition)
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func UpdateDatabase(activity: Tradition) {
        if activity.id != "" {
            let ref = Firestore.firestore().collection("completed_activities")
            ref.document().setData(activity.submissionDictionary) { err in
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
                vc.selectedActivity = tradition
            }
        }
    }
    
}
