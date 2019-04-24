//
//  TableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var traditions: [SubmittedTradition] = []
    private var documents: [DocumentSnapshot] = []
    
    var selectedUser: User!
    
    private var selectedActivityIndex: Int!
    
    private var DateFormat = DateFormatter()
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var ProgressLabel: UILabel!
    
    private var backgroundView = UIImageView()
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    
    private var db: Firestore {
        return Firestore.firestore()
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
            let models = snapshot.documents.map { (document) -> SubmittedTradition in
                if let model = SubmittedTradition(dictionary: document.data(), id: document.documentID) {
                    return model
                } else {
                    print("Unable to initialize type \(SubmittedTradition.self) with dictionary \(document.data())")
                    return SubmittedTradition()
                }
            }
            self.traditions = models
            self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                self.TableView.backgroundView = nil
            } else {
                self.TableView.backgroundView = self.backgroundView
            }
            
            DispatchQueue.main.async {
                self.TableView.reloadData()
            }
            
        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        return db.collection("submissions").limit(to: 20).whereField("user", isEqualTo: selectedUser.name_FL)
    }
    
    deinit {
        listener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
    }
    
    private func prepareView() {
        DateFormat.dateStyle = .short
        DateFormat.timeStyle = .none
        DateFormat.locale = Locale(identifier: "en_US")
        
        UserNameLabel.text = selectedUser.name_FL
        ProgressLabel.text = "Progress: \(selectedUser.uid)%"
        
        query = baseQuery()
        
        let userProgress = "Required: \(selectedUser.requiredComplete) - Optional: \(selectedUser.optionalComplete)"
        ProgressLabel.text = userProgress
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return traditions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tradition = traditions[indexPath.row]
        let cell = TraditionTableViewCell.cellForTableView(tableView: tableView, atIndex: indexPath, submission: tradition)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedActivityIndex = indexPath.row
        performSegue(withIdentifier: "SubmissionDetail", sender: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "SubmissionDetail":
            if let vc = segue.destination as? SubmissionsViewController {
            }
        
        default:
            break;
        }
    }
    
}
