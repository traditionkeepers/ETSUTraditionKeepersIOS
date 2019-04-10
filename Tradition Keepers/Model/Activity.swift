//
//  Activity.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

/// Class for containg information relating to Activities.
class Activity: Equatable, Comparable {
    
    struct CompletionData {
        var status: ActivityStatus = .none
        var user_id: String = ""
        var date: Date = Date()
        var activity_ref: DocumentReference?
    }
    
    static var db = User.db
    
    var id: String?
    var title: String
    var instruction: String
    var category: String
    var date: Date
    var location: Location
    var completion: CompletionData
    
    
    /// Returns a dictionary containing the parameters for an activty in the completion table.
    var Completed: [String: Any] {
        
        let ActivityData: [String:Any] = [
            "title": title
        ]
        
        let CompletionData: [String:Any] = [
            "user_id": User.uid,
            "status": completion.status.rawValue,
            "date": Timestamp(date: completion.date),
            "activity_ref": completion.activity_ref ?? "",
            "activity_data": ActivityData
        ]
        
        return CompletionData
    }
    
    
    /// Returns a Dictionary containing the parameters for any activity in the activity table.
    var Info: [String:Any] {
        let ActivityData: [String: Any] = [
            "title": title,
            "instruction": instruction,
            "date": Timestamp(date: date),
            "category": category,
            "location_name": location.name,
            "location": location.point
        ]
        
        return ActivityData
    }
    
    
    /// Creates a new activity with default parameters.
    init() {
        title = ""
        instruction = ""
        category = ""
        date = Date()
        location = Location()
        completion = CompletionData()
    }
    
    
    /// Creates a new activity from the fields from a Firestore DocumentSnapshot.
    ///
    /// - Parameter doc: The document fetched from Firestore.
    init(fromDoc doc: DocumentSnapshot) {
        self.completion = CompletionData()
        let data = doc.data()!
        
        // Check if activity is completed
        if let status = data["status"] as? String {
            // Set status field
            switch status {
            case "Pending":
                self.completion.status = .pending
            case "Verified":
                self.completion.status = .verified
            default:
                self.completion.status = .none
            }
            
            // Set Date field
            self.completion.date = (data["date"] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: TimeInterval(exactly: 0.0)!)
            self.completion.user_id = data["user_id"] as? String ?? ""
            self.completion.activity_ref = data["activity_ref"] as? DocumentReference
            self.id = doc.documentID
            
            let activity_data = data["activity_data"] as! [String: Any]
            title = activity_data["title"] as? String ?? ""
            instruction = activity_data["instruction"] as? String ?? ""
            category = activity_data["category"] as? String ?? ""
            date = (activity_data["date"] as? Timestamp)?.dateValue() ?? Date()
            let geo = activity_data["location"] as? GeoPoint
            let name = data["location_name"] as? String ?? ""
            location = Location(name: name, latitude: geo?.longitude, longitude: geo?.latitude)
            
        } else {
            let data = doc.data()!
            
            title = data["title"] as? String ?? ""
            instruction = data["instruction"] as? String ?? ""
            category = data["category"] as? String ?? ""
            date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
            if let geo = data["location"] as? GeoPoint {
                let name = data["location_name"] as? String ?? ""
                location = Location(name: name, latitude: geo.longitude, longitude: geo.latitude)
            } else {
                location = Location()
            }
            
            self.id = doc.documentID
        }
    }
    
    
    /// Creates a new activity from the input fields.
    ///
    /// - Parameters:s
    ///   - data: A dictionary of values for the activity's parameters.
    ///   - status: Enumerated value describing current status.
    init(data: [String:Any], withStatus status: ActivityStatus = .none) {
        title = data["title"] as? String ?? ""
        instruction = data["instruction"] as? String ?? ""
        date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
        category = data["category"] as? String ?? ""
        if let geo = data["location"] as? GeoPoint {
            let name = data["location_name"] as? String ?? ""
            location = Location(name: name, latitude: geo.longitude, longitude: geo.latitude)
        } else {
            location = Location()
        }
        
        
        self.completion = CompletionData()
        self.completion.date = Date()
        self.completion.user_id = ""
        self.completion.status = status
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
        
        if let left = lhs.completion.activity_ref{
            lPath = left.path
        }
        if let right = rhs.completion.activity_ref{
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

class Location {
    var name: String
    var coordinate: CLLocation
    var id: String {
        return name.lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    var latitude: Double {
        return coordinate.coordinate.latitude
    }
    
    var longitude: Double {
        return coordinate.coordinate.longitude
    }
    
    var point: GeoPoint {
        return GeoPoint(latitude: latitude, longitude: longitude)
    }
    
    init() {
        self.name = "Not Set"
        self.coordinate  = CLLocation(latitude: 36.323675, longitude: -82.346314)
    }
    
    init(fromDoc doc: DocumentSnapshot) {
        self.name = doc.get("title") as? String ?? "Not Set"
        let geo = doc.get("coordinate") as! GeoPoint
        self.coordinate = CLLocation(latitude: geo.latitude, longitude: geo.longitude)
    }
    
    init(name: String, coordinate: CLLocation) {
        self.name = name
        self.coordinate = coordinate
    }
    
    init(name: String, latitude: Double?, longitude: Double?) {
        self.name = name
        self.coordinate = CLLocation(latitude: longitude ?? -82.346314, longitude: latitude ?? 36.323675)
    }
}
