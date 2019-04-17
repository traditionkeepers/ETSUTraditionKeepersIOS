//
//  TableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices

class DashboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private var submissionImage: UIImage!
    
    private var topThree: [Tradition] = [] {
        didSet {
            TopThreeTable.reloadData()
        }
    }
    
    private var selectedIndex: Int!
    private var DateFormat = DateFormatter()
    
    @IBOutlet weak var TopThreeTable: UITableView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DateFormat.dateStyle = .short
        DateFormat.timeStyle = .none
        DateFormat.locale = Locale(identifier: "en_US")
    }
    
    
    
    
    func SetupView(_ animated: Bool = false) {
        usernameButton.setTitle("Welcome, \(User.current.first)", for: .normal)
        progressButton.setTitle(User.current.uid, for: .normal)
        if let selectionIndexPath = TopThreeTable.indexPathForSelectedRow {
            TopThreeTable.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        GetTopThree()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        SetupView(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
                vc.tradition = topThree[selectedIndex]
            }
        case "Submit":
            if let vc = segue.destination as? SubmitViewController {
                if let sender = sender as? TraditionTableViewCell {
//                    vc.tradition = sender.tradition
                }
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
        return topThree.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TraditionTableViewCell.cellForTableView(tableView: tableView, atIndex: indexPath)
        let tradition = topThree[indexPath.row]
        cell.tradition = tradition
        cell.CompleteButtonPressed = { sender in
            self.performSegue(withIdentifier: "Submit", sender: cell)
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
    func UpdateDatabase(activity: Tradition) {
        if activity.id != "" {
            Firestore.firestore().collection("completed_activities").document().setData(activity.submissionDictionary) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
    }
    
    func GetTopThree() {
        var activities :[Tradition] = []
        Firestore.firestore().collection("traditions").limit(to: 3).getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Tradition(dictionary: doc.data(), id: doc.documentID)!)
                }
                self.topThree = activities
            }
        })
    }
}
