//
//  Activity.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
import Firebase

class Activity: Equatable, Comparable {
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id ?? "" == rhs.id ?? ""
    }
    
    static func < (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id ?? "" < rhs.id ?? ""
    }
    
    static func > (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id ?? "" > rhs.id ?? ""
    }
    
    
    static var db = User.db
    static var categories: [String]?
    
    var data: [String: Any]
    var status: ActivityStatus
    var id: String?
    
    var completed: [String: Any] {
        return [
            "activity_id": id!,
            "user_id": User.uid,
            "date": data["date"]!,
            "status": "pending"
        ]
    }
    
    init()
    {
        data = [
            "title": "",
            "instruction": "",
            "category": "",
            "date": Timestamp(date: Date())
        ]
        status = .none
    }
    
    init(fromDoc doc: DocumentSnapshot) {
        data = [
            "title": doc.data()?["title"] as! String,
            "instruction": doc.data()?["instruction"] as! String,
            "category": doc.data()?["category"] as! String,
            "date": doc.data()?["date"] as! Timestamp
            ]
        if let id = doc.data()?["activity_id"] {
            self.id = id as? String
            let status = doc.data()?["status"] as? String
            switch status {
            case "Pending":
                self.status = .pending
            case "Verified":
                self.status = .verified
            default:
                self.status = .none
            }
        } else {
            self.id = doc.documentID
            self.status = .none
        }
    }
    
    init(data: [String:Any], withStatus status: ActivityStatus = .none) {
        self.data = data
        self.status = status
    }
}

enum ActivityStatus: String {
    case none = "Complete"
    case pending = "Pending"
    case verified = "Verified"
}
