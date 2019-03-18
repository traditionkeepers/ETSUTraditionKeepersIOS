//
//  TableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class DashboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    private var topThree: [Activity]? {
        didSet {
            TopThreeTable.reloadData()
        }
    }
    private var selectedIndex: Int!
    private var DateFormat = DateFormatter()
    
    private var currentUser: User = User() {
        didSet {
            let tabs = self.tabBarController?.viewControllers ?? []
            for tab in tabs {
                if let nc = tab as? UINavigationController {
                    if let vc = nc.topViewController as? ActivityCollectionViewController {
                        vc.currentUser = self.currentUser
                        print("Found Collection")
                    }
                } else {
                    print("Found Something Else")
                }
            }
            usernameButton.setTitle("Welcome, \(currentUser.data.first) \(currentUser.data.last)", for: UIControl.State.normal)
            progressButton.setTitle("Progress: \(currentUser.data.uid)%", for: UIControl.State.normal)
        }
    }
    
    @IBOutlet weak var TopThreeTable: UITableView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DateFormat.dateStyle = .short
        DateFormat.timeStyle = .none
        DateFormat.locale = Locale(identifier: "en_US")
        
        GetUserData()
        GetTopThree()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let selectionIndexPath = TopThreeTable.indexPathForSelectedRow {
            TopThreeTable.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func pressedUserButton(_ sender: Any) {
        performSegue(withIdentifier: "ShowUserDetail", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "ShowActivityDetail":
            if let vc = segue.destination as? ActivityDetailViewController {
                vc.currentUser = self.currentUser
                vc.selectedActivity = topThree?[selectedIndex]
            }
        case "ShowUserDetail":
            if let vc = segue.destination as? ProfileViewController {
                vc.currentUser = self.currentUser
            }
        default:
            break
        }
    }
}

// MARK: - Table view data source
extension DashboardTableViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return topThree?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityTableViewCell
        cell.NameLabel.text = topThree?[indexPath.row].activity_data["title"] as? String
        cell.SecondaryLabel.text = topThree?[indexPath.row].activity_data["instruction"] as? String
        
        let status = topThree?[indexPath.row].status ?? .none
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
            if let date = topThree?[indexPath.row].completion_data["date"] as? Timestamp {
                cell.CompleteButton.setTitle(DateFormat.string(from: date.dateValue()), for: .normal)
                cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
                cell.CompleteButtonPressed = nil
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "ShowActivityDetail", sender: nil)
    }
}

// MARK: Firebase
extension DashboardTableViewController {
    func ShowAlertForRow(row: Int) {
        print("Complete Button Pressed")
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            self.topThree?[row].status = .pending
            self.topThree?[row].completion_data["user_id"] = User.uid
            self.topThree?[row].completion_data["activity_ref"] = Activity.db.document("activities/\(self.topThree?[row].id ?? "")")
            self.topThree?[row].completion_data["date"] = Timestamp(date: Date())
            self.UpdateDatabase(activity: self.topThree![row])
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func UpdateDatabase(activity: Activity) {
        if activity.id != nil {
            Activity.db.collection("completed_activities").document().setData(activity.completed) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
    }
    
    func GetUserData() {
        let docref = Activity.db.collection("users").document(currentUser.data.uid)
        docref.getDocument(completion: { (document, error) in
            if let document = document, document.exists {
                self.currentUser = User(fromDoc: document)
            } else {
                print("Error fetching user doc! \(String(describing: error))")
            }
        })
    }
    
    func GetTopThree() {
        var activities :[Activity] = []
        Activity.db.collection("activities").limit(to: 3).getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Activity(fromDoc: doc))
                }
                self.topThree = activities
            }
        })
    }
}
