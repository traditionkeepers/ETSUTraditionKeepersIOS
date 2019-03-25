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
    
    static var uid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    static var currentUser = User() {
        didSet {
            print("User set! - \(User.permission)")
        }
    }
    static var permission: UserPermission {
        get {
            return currentUser.data.permission
        }
    }
    
    var data: UserData
    
    init() {
        data = UserData()
        data.first = ""
        data.last = "Guest"
        data.permission = .none
    }
    
    init(fromDoc doc: DocumentSnapshot) {
        data = UserData()
        data.first = doc.get("first") as? String ?? ""
        data.last = doc.get("last") as? String ?? ""
        data.uid = User.uid
        
        let permission = doc.get("permission") as? String ?? ""
        switch permission {
            case "user": data.permission = .user
            case "staff": data.permission = .staff
            case "admin": data.permission = .admin
            default: data.permission = .none
        }
    }
}

struct UserData {
    var first = "",
    last = "",
    uid = "",
    permission: UserPermission = .none
}

enum UserPermission {
    case none
    case user
    case staff
    case admin
}
