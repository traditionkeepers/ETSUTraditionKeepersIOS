//
//  SubmissionsViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/12/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class SubmissionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var TableView: UITableView!

    private var backgroundView = UIImageView()
    private var submissions: [SubmittedTradition] = []
    private var groups: [String:[SubmittedTradition]] = [:]
    private var documents: [DocumentSnapshot] = []
    
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
            let models = snapshot.documents.map { (document) -> SubmittedTradition in
                if let model = SubmittedTradition(dictionary: document.data(), id: document.documentID) {
                    return model
                } else {
                    print("Unable to initialize type \(SubmittedTradition.self) with dictionary \(document.data())")
                    return SubmittedTradition()
                }
            }
            self.submissions = models
//            if self.sort == .category {
//                self.groups = Dictionary(grouping: models, by: { $0.category.name })
//            } else {
//                self.groups = Dictionary(grouping: models, by: { $0.title.first?.description ?? "" })
//            }
            
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
//        whereField("status", isEqualTo: "pending")
        return db.collection("submissions").limit(to: 20)
    }
    
    deinit {
        listener?.remove()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return submissions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let submission = submissions[indexPath.row]
        let cell = TraditionTableViewCell.cellForTableView(tableView: tableView, atIndex: indexPath, submission: submission)
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        query = baseQuery()
        observeQuery()
        self.title = "Submissions"
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
