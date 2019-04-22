//
//  UsersTableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/3/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class UsersTableViewController: UIViewController {

    @IBOutlet var UserTable: UITableView!
    
    let backgroundView = UIImageView()
    
    private var users: [User] = []
    private var groups: [String:[User]] = [:]
    private var documents: [DocumentSnapshot] = []
    
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
            let models = snapshot.documents.map { (document) -> User in
                if let model = User(dictionary: document.data(), id: document.documentID) {
                    return model
                } else {
                    print("Unable to initialize type \(User.self) with dictionary \(document.data())")
                    return User()
                }
            }
            
            self.users = models
            self.groups = Dictionary(grouping: models, by: { $0.last.first!.description })
            self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                self.UserTable.backgroundView = nil
            } else {
                self.UserTable.backgroundView = self.backgroundView
            }
            
            DispatchQueue.main.async {
                self.UserTable.reloadData()
            }
            
        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        return db.collection("users").limit(to: 20)
    }
    
    deinit {
        listener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query = baseQuery()
        
        UserTable.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
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

// MARK: - Table View
extension UsersTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = groups.keys.count
        return count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title =  groups.keys.sorted()[section]
        return title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = groups.keys.sorted()[section]
        let count = groups[key]!.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "UserCell")
        let key = groups.keys.sorted()[indexPath.section]
        let user = groups[key]![indexPath.row]
        
        let firstAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor(named: "ETSU WHITE")
        ]
        
        let lastAttributes: [NSAttributedString.Key: Any] = [
            .font:UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(named: "ETSU WHITE")
        ]
        
        let nameString = NSMutableAttributedString(string: user.first + " ", attributes: firstAttributes)
        nameString.append(NSAttributedString(string: user.last, attributes: lastAttributes))
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.attributedText = nameString
        
        return cell
    }
}
