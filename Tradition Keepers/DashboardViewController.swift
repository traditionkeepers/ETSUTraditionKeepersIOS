//
//  DashboardViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/25/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class DashboardViewController: UIViewController {
    
    var db: Firestore!
    var userInfo: DocumentSnapshot!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        if let currentUser = Auth.auth().currentUser {
            let docref = db.collection("users").document(currentUser.uid)
            docref.getDocument() { (document, error) in
                if let document = document {
                    self.userInfo = document
                    self.fillData()
                } else {
                    print(error?.localizedDescription ?? "An error occured")
                }
            }
        }
    }
    
    func fillData() {
        usernameLabel.text = "Welcome, \(userInfo.get("first") as? String ?? "") \(userInfo.get("last") as? String ?? "")"
        idLabel.text = Auth.auth().currentUser?.uid
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
