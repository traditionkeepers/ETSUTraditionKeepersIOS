//
//  Activity.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
import Firebase


/// Class for containg information relating to Activities.
class Activity: Equatable, Comparable {
    static var db = User.db
    
    var activity_data: [String: Any] = [:]
    var completion_data: [String: Any] = [:]
    var status: ActivityStatus
    var id: String?
    
    
    /// Returns a dictionary containing the parameters for an activty in the completion table.
    var completed: [String: Any] {
        var temp = completion_data
        temp["status"] = status.rawValue
        temp["activity_info"] = activity_data
        return temp
    }
    
    
    /// Creates a new activity with default parameters.
    init() {
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
    
    
    /// Creates a new activity from the fields from a Firestore DocumentSnapshot.
    ///
    /// - Parameter doc: The document fetched from Firestore.
    init(fromDoc doc: DocumentSnapshot) {
        // Check if document is completed
        if doc.data()?["status"] != nil {
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
            if let activity_data = doc.data()?["activity_info"] as? [String: Any] {
                self.activity_data = activity_data
            }
        } else {
            if let data = doc.data() {
                activity_data = data
            }
            self.id = doc.documentID
            self.status = .none
        }
    }
    
    
    /// Creates a new activity from the input fields.
    ///
    /// - Parameters:
    ///   - data: A dictionary of values for the activity's parameters.
    ///   - status: Enumerated value describing current status.
    init(data: [String:Any], withStatus status: ActivityStatus = .none) {
        self.activity_data = data
        completion_data = [
            "date": Timestamp(),
            "user_id": ""
            // "activity_ref": DocumentReference
        ]
        self.status = status
    }
    
    
    /// Implemented Equatable function comparing by Firestore activity ID.
    ///
    /// - Parameters:
    ///   - lhs: The first input Activity.
    ///   - rhs: The second input Activity.
    /// - Returns: Returns "true" if both Activities have the same path, "false" otherwise.
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
    
    
    /// Implemented Comparable function comparing activities by ID.
    ///
    /// - Parameters:
    ///   - lhs: The first input activity.
    ///   - rhs: The second input activity.
    /// - Returns: Returns "true" if the left ID is less than the right ID.
    static func < (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id ?? "" < rhs.id ?? ""
    }
    
    
    /// Implemented Comparable function comparing activities by ID.
    ///
    /// - Parameters:
    ///   - lhs: The first input activity
    ///   - rhs: The second input activity
    /// - Returns: Returns "true" if the left ID is greater than the right ID.
    static func > (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id ?? "" > rhs.id ?? ""
    }
}


/// Enumerated values for an activity's status
///
/// - none: Activity has not been submitted for completion. Contains Raw value "Complete".
/// - pending: Activity has been submitted for completion, but has not been verified. Contains Raw value "Pending".
/// - verified: Activity has been submitted and verified for completion. Contains Raw value "Verified".
enum ActivityStatus: String {
    case none = "Complete"
    case pending = "Pending"
    case verified = "Verified"
}
