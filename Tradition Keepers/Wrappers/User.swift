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
    
    var data: UserData
    
    init() {
        data = UserData()
        data.first = "first"
        data.last = "last"
        data.uid = Auth.auth().currentUser?.uid ?? ""
        data.permission = .user
    }
    
    init(fromDoc doc: DocumentSnapshot) {
        data = UserData()
        data.first = doc.get("first") as? String ?? ""
        data.last = doc.get("last") as? String ?? ""
        data.uid = Auth.auth().currentUser?.uid ?? ""
        data.permission = .user
    }
}

struct UserData {
    var first = "",
    last = "",
    uid = "",
    permission: UserPermission = .user
}

enum UserPermission {
    case user
    case staff
    case admin
}
