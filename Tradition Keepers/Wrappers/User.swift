//
//  User.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
import Firebase

class User {
    static var db: Firestore {
        get {
            Firestore.firestore().settings = FirestoreSettings()
            return Firestore.firestore()
        }
    }
    
    static var dataDoc: DocumentSnapshot? {
        get {
            var doc: DocumentSnapshot?
            if let currentUser = Auth.auth().currentUser {
                let docref = db.collection("users").document(currentUser.uid)
                docref.getDocument { (document, error) in
                    if let document = document, document.exists {
                        doc = document
                    } else {
                        print(error?.localizedDescription ?? "An error occured")
                    }
                }
            }
            return doc
        }
    }
    
    static var first: String {
        get {
            if let doc = dataDoc {
                return doc.get("first") as? String ?? ""
            }
            return ""
        }
    }
    
    static var last: String {
        get {
            if let doc = dataDoc {
                return doc.get("last") as? String ?? ""
            }
            return ""
        }
    }
    
    static var uid: String {
        get {
            if let user = Auth.auth().currentUser {
                return user.uid
            }
            return ""
        }
    }
    
    static var completedActivities: QuerySnapshot? {
        get {
            var docs: QuerySnapshot?
            db.collection("completed_activities").whereField("uid", isEqualTo: uid).getDocuments(completion: { (QuerySnapshot, err) in
                if let err = err {
                    print("Error retreiving documents: \(err)")
                } else {
                    docs = QuerySnapshot
                }
            })
            return docs
        }
    }
}
