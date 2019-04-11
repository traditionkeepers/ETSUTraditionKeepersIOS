//
//  User.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Firebase

struct User {
    var uid: String
    var first: String
    var last: String
    var permission: UserPermission
    
    var name_FL: String {
        return first + " " + last
    }
    
    var name_LF: String {
        return last + ", " + first
    }
    
    var dictionary: [String: Any] {
        return [
            "first": first,
            "last": last,
            "permission": permission.rawValue
        ]
    }
    
    static var current: User = User()
}

extension User: DocumentSerializable {
    static let permission: [String: UserPermission] = [
        "none": .none,
        "user": .user,
        "staff": .staff,
        "admin": .admin
    ]
    
    init() {
        uid = ""
        first = "Anonomous"
        last = ""
        permission = .none
    }
    
    init?(dictionary: [String : Any]) {
        guard let uid = dictionary["uid"] as? String,
            let first = dictionary["first"] as? String,
            let last = dictionary["last"] as? String,
            let permission = User.permission[dictionary["permission"] as? String ?? "none"]
            else { return nil }
        
        self.init(uid: uid,
                  first: first,
                  last: last,
                  permission: permission)
    }
}

enum UserPermission: String {
    case none = "none"
    case user = "user"
    case staff = "staff"
    case admin = "admin"
}
    
    
//    static let ref = Activity.db.collection("users")
//
//    static var onUpdate: ((_ user: User)-> ())?
//    static var currentUser = User() {
//        didSet {
//            print("User set! - \(User.permission)")
//            onUpdate?(currentUser)
//        }
//    }
//
//    static func LogIn(username: String, password: String, completion: @escaping (_ success: Error?) -> Void) {
//        Auth.auth().signIn(withEmail: username, password: password) { (user, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                completion(error)
//            } else if user != nil {
//                self.FetchUserData(completion: {error in
//                    if let error = error {
//                        completion(error)
//                        print("Failure fetching data")
//                    } else {
//                        completion(nil)
//                    }
//                })
//            }
//        }
//
//        currentUser = User()
//    }
//
//    func LogOut() {
//        do {
//            try Auth.auth().signOut()
//            User.currentUser = User()
//        } catch let signOutError as NSError {
//            print("Error signing out: \(signOutError)")
//            User.currentUser = User()
//        }
//    }
//
//    func FetchUserData(completion: @escaping (_ error: Error?) -> Void) {
//        print("Fetching User Data")
//        let docref = ref.document(uid)
//        docref.getDocument(completion: { (document, error) in
//            if let document = document, document.exists {
//                print("User Found!")
//                currentUser = User(fromDoc: document)
//                completion(nil)
//            } else {
//                print("Error fetching user doc! \(String(describing: error))")
//                completion(error)
//            }
//        })
//    }
//
//    static var db: Firestore {
//        get {
//            Firestore.firestore().settings = FirestoreSettings()
//            return Firestore.firestore()
//        }
//    }
//
//    static var uid: String {
//        return Auth.auth().currentUser?.uid ?? ""
//    }
//
//
//    static var permission: UserPermission {
//        get {
//            return currentUser.permission
//        }
//    }
//
//    init() {
//        uid = ""
//        first = ""
//        last = "Guest"
//        permission = .none
//    }
//
//    init(fromDoc doc: DocumentSnapshot) {
//        first = doc.get("first") as? String ?? ""
//        last = doc.get("last") as? String ?? "Guest"
//        uid = User.uid
//
//        let _permission = doc.get("permission") as? String ?? "none"
//        switch _permission {
//        case "user": permission = .user
//        case "staff": permission = .staff
//        case "admin": permission = .admin
//        default: permission = .none
//        }
//    }
//}
//
