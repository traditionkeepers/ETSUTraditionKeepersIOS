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
        var lPath = "activities/\(lhs.id ?? "")"
        var rPath = "activities/\(rhs.id ?? "")"
        
        if let left = lhs.completion_data["activity_ref"] as? DocumentReference {
            lPath = left.path
        }
        if let right = rhs.completion_data["activity_ref"] as? DocumentReference {
            rPath = right.path
        }
        
        return lPath == rPath
    }
    
    static func < (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id ?? "" < rhs.id ?? ""
    }
    
    static func > (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id ?? "" > rhs.id ?? ""
    }
    
    
    static var db = User.db
    static var categories: [String]?
    
    var activity_data: [String: Any] = [:]
    var completion_data: [String: Any] = [:]
    var status: ActivityStatus
    var id: String?
    
    var completed: [String: Any] {
        var temp = completion_data
        temp["status"] = status.rawValue
        temp["activity_info"] = activity_data
        return temp
    }
    
    init()
    {
        status = .none
        
        activity_data = [
            "title": "",
            "instruction": "",
            "category": "",
            "date": Timestamp(date: Date())
        ]
        
        completion_data = [
            "date": Timestamp(),
            "user_id": ""
        // "activity_ref": DocumentReference
        ]
        
    }
    
    init(fromDoc doc: DocumentSnapshot) {
        // Check if document is completed
        if doc.data()?["status"] != nil {
            print("From Completed")
            
            // Set status field
            switch doc.data()?["status"] as? String {
            case "Pending":
                self.status = .pending
            case "Verified":
                self.status = .verified
            default:
                self.status = .none
            }
            
            // Set Date field
            self.completion_data["date"] = doc.data()?["date"] as? Timestamp
            self.completion_data["user_id"] = doc.data()?["user_id"] as? String
            self.completion_data["activity_ref"] = doc.data()?["activity_ref"] as! DocumentReference
            
            self.id = doc.documentID
            
            print("Populated CompletionInfo")
            
            print("Setting data")
            if let activity_data = doc.data()?["activity_info"] as? [String: Any] {
                self.activity_data = activity_data
            }
            print("Complete!")
        } else {
            print("From Standard")
            if let data = doc.data() {
                activity_data = data
            }
            
            self.id = doc.documentID
            self.status = .none
            
        }
    }
    
    init(data: [String:Any], withStatus status: ActivityStatus = .none) {
        self.activity_data = data
        completion_data = [
            "date": Timestamp(),
            "user_id": ""
            // "activity_ref": DocumentReference
        ]
        self.status = status
    }
}

enum ActivityStatus: String {
    case none = "Complete"
    case pending = "Pending"
    case verified = "Verified"
}
