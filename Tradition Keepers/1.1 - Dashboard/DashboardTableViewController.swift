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
    
    let backgroundView = UIImageView()
//    private var addedData: [Tradition] = []
//    private var modifiedData: [Tradition] = []
//    private var removedData: [Tradition] = []
    private var data: [Any] = []
    private var documents: [DocumentSnapshot] = []
    
    private var selectedIndex: Int!
    
    @IBOutlet weak var TopTraditionTable: UITableView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    
    private var db: Firestore!
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
            
//            snapshot.documentChanges.forEach({ (diff) in
//                switch diff.type {
//                case .added:
//                    self.addedData.append(Tradition(dictionary: diff.document.data(), id: diff.document.documentID)!)
//                case .modified:
//                    self.modifiedData.append(Tradition(dictionary: diff.document.data(), id: diff.document.documentID)!)
//                case .removed:
//                    self.removedData.append(Tradition(dictionary: diff.document.data(), id: diff.document.documentID)!)
//                default:
//                    print("Unable to initialize type \(Tradition.self) with dictionary \(diff.document.data())")
//                }
//            })
            
            let models = snapshot.documents.map { (document) -> Tradition in
                if let model = Tradition(dictionary: document.data(), id: document.documentID) {
                    return model
                } else {
                    print("Unable to initialize type \(Tradition.self) with dictionary \(document.data())")
                    return Tradition()
                }
            }
            
            self.data = models
            self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                self.TopTraditionTable.backgroundView = nil
            } else {
                self.TopTraditionTable.backgroundView = self.backgroundView
            }
            
            DispatchQueue.main.async {
                self.TopTraditionTable.beginUpdates()
                let range = IndexSet(arrayLiteral: 0, self.TopTraditionTable.numberOfSections)
                self.TopTraditionTable.reloadSections(range, with: .automatic)
                self.TopTraditionTable.endUpdates()
//                self.TopTraditionTable.reloadData()
            }
        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        var query = db.collection("traditions").limit(to: 5)
        query = Permission.allowApproval ? db.collection("submissions").limit(to: 5) : query
        return query
    }
    
    deinit {
        listener?.remove()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        query = baseQuery()
    }
    
    func SetupView(_ animated: Bool = false) {
        TopTraditionTable.backgroundColor = .clear
        usernameButton.setTitle("Welcome, \(User.current.first)", for: .normal)
        let userProgress = "Required: \(User.current.requiredComplete) - Optional: \(User.current.optionalComplete)"
        progressButton.setTitle(userProgress, for: .normal)
        if let selectionIndexPath = TopTraditionTable.indexPathForSelectedRow {
            TopTraditionTable.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        SetupView(animated)
        observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        stopObserving()
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
                if let tradition = data[selectedIndex] as? Tradition {
                    vc.tradition = tradition
                }
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
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Permission.allowSubmission {
            print("Dequing Tradition")
            let tradition = data[indexPath.row] as! Tradition
            let cell = TraditionTableViewCell.cellForTableView(tableView: tableView, atIndex: indexPath, tradition: tradition)
            cell.CompleteButtonPressed = { sender in
                self.performSegue(withIdentifier: "Submit", sender: cell)
            }
            return cell
        } else if Permission.allowApproval {
            print("Dequing Submission")
            let submission = data[indexPath.row] as! SubmittedTradition
            let cell = TraditionTableViewCell.cellForTableView(tableView: tableView, atIndex: indexPath, submission: submission)
            cell.CompleteButtonPressed = { sender in
                self.performSegue(withIdentifier: "Submit", sender: cell)
            }
            return cell
        }
        
        return TraditionTableViewCell.cellForTableView(tableView: tableView, atIndex: indexPath, tradition: nil)
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
}
