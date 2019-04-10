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
    static let ref = Activity.db.collection("users")
    
    static var onUpdate: ((_ user: User)-> ())?
    static var currentUser = User() {
        didSet {
            print("User set! - \(User.permission)")
            onUpdate?(currentUser)
        }
    }
    
    static func LogIn(username: String, password: String, completion: @escaping (_ success: Error?) -> Void) {
        Auth.auth().signIn(withEmail: username, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            } else if user != nil {
                self.FetchUserData(completion: {error in
                    if let error = error {
                        completion(error)
                        print("Failure fetching data")
                    } else {
                        completion(nil)
                    }
                })
            }
        }
        
        currentUser = User()
    }
    
    static func LogOut() {
        do {
            try Auth.auth().signOut()
            currentUser = User()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
        
        
    }
    
    static func FetchUserData(completion: @escaping (_ error: Error?) -> Void) {
        print("Fetching User Data")
        let docref = ref.document(User.uid)
        docref.getDocument(completion: { (document, error) in
            if let document = document, document.exists {
                print("User Found!")
                currentUser = User(fromDoc: document)
                completion(nil)
            } else {
                print("Error fetching user doc! \(String(describing: error))")
                completion(error)
            }
        })
    }
    
    static var db: Firestore {
        get {
            Firestore.firestore().settings = FirestoreSettings()
            return Firestore.firestore()
        }
    }
    
    static var uid: String {
        return Auth.auth().currentUser?.uid ?? ""
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
