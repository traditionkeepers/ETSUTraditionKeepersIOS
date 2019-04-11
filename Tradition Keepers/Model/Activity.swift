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

struct Tradition {
    // General Activity Data
    var id: String?
    var title: String
    var instruction: String
    var category: Category
    var date: Date
    var location: Location
    
    var activityDictionary: [String:Any] {
        return [
            "title": title,
            "instruction": instruction,
            "date": Timestamp(date: date),
            "category": category.name,
            "location_name": location.name,
            "location": location.point
        ]
    }
}

extension Tradition: DocumentSerializable {
    init() {
        id = nil
        title = "New Tradition"
        instruction = "Empty"
        date = Date()
        category = Category.categories["general"] ?? Category(name: "General", count: 0)
        location = Location()
    }
    
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
        let title = dictionary["title"] as? String,
        let instruction = dictionary["instruction"] as? String,
        let catname = dictionary["category"] as? String,
        let date = (dictionary["date"] as? Timestamp)?.dateValue(),
        let geo = dictionary["location"] as? [String: Any]
            else { return nil }
        
        let category = Category.categories[catname] ?? Category(name: catname, count: 1)
        let location = Location(dictionary: geo)!
        
        self.init(id: id,
                  title: title,
                  instruction: instruction,
                  category: category,
                  date: date,
                  location: location)
    }
}

struct SubmittedTradition {
    var status: ActivityStatus
    var user_id: String
    var completion_date: Date
    var activity_ref: DocumentReference?
    var tradition: Tradition?
    
    var dictionary: [String:Any] {
        return [
            "user_id": user_id,
            "status": status.rawValue,
            "date": Timestamp(date: completion_date),
            "activity_ref": activity_ref!
        ]
    }
}

extension SubmittedTradition: DocumentSerializable {
    static let status: [String: ActivityStatus] = [
        "none": .none,
        "pending": .pending,
        "verified": .verified
    ]
    
    init() {
        status = .none
        user_id = ""
        completion_date = Date()
        activity_ref = nil
    }
    
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["user_id"] as? String,
        let date = (dictionary["date"] as? Timestamp)?.dateValue(),
        let status = SubmittedTradition.status[dictionary["status"] as? String ?? "none"],
        let ref = dictionary["activity_ref"] as? DocumentReference
        else { return nil }
        
        self.init(status: status,
                  user_id: id,
                  completion_date: date,
                  activity_ref: ref,
                  tradition: nil)
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

struct Location {
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
    
    var dictionary: [String:Any] {
        return [
            "name": name,
            "coordinate": point
        ]
    }
}

extension Location: DocumentSerializable {
    init() {
        name = "Default"
        coordinate = CLLocation(latitude: 36.323675, longitude: -82.346314)
    }
    
    init(name: String, coordinate: CLLocation?) {
        self.name = name
        self.coordinate = coordinate ?? CLLocation(latitude: 36.323675, longitude: -82.346314)
    }
    
    init(name: String, latitude: Double?, longitude: Double?) {
        self.name = name
        self.coordinate = CLLocation(latitude: longitude ?? -82.346314, longitude: latitude ?? 36.323675)
    }
    
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
            let geo = dictionary["coordinate"] as? GeoPoint
            else { return nil }
        
        let coordinate = CLLocation(latitude: geo.latitude, longitude: geo.longitude)
        self.init(name: name, coordinate: coordinate)
    }
}

//class Activity: Equatable, Comparable {
//    /// Returns a dictionary containing the parameters for an activty in the completion table.
//    var Completed: [String: Any] {
//
//        let ActivityData: [String:Any] = [
//            "title": title
//        ]
//
//        let CompletionData: [String:Any] = [
//            "user_id": User.uid,
//            "status": completion.status.rawValue,
//            "date": Timestamp(date: completion.date),
//            "activity_ref": completion.activity_ref ?? "",
//            "activity_data": ActivityData
//        ]
//
//        return CompletionData
//    }
//
//
//    /// Returns a Dictionary containing the parameters for any activity in the activity table.
//    var Info: [String:Any] {
//        let ActivityData: [String: Any] = [
//            "title": title,
//            "instruction": instruction,
//            "date": Timestamp(date: date),
//            "category": category,
//            "location_name": location.name,
//            "location": location.point
//        ]
//
//        return ActivityData
//    }
//
//
//    /// Creates a new activity with default parameters.
//    init() {
//        title = ""
//        instruction = ""
//        category = ""
//        date = Date()
//        location = Location()
//        completion = CompletionData()
//    }
//
//
//    /// Creates a new activity from the fields from a Firestore DocumentSnapshot.
//    ///
//    /// - Parameter doc: The document fetched from Firestore.
//    init(fromDoc doc: DocumentSnapshot) {
//        self.completion = CompletionData()
//        let data = doc.data()!
//
//        // Check if activity is completed
//        if let status = data["status"] as? String {
//            // Set status field
//            switch status {
//            case "Pending":
//                self.completion.status = .pending
//            case "Verified":
//                self.completion.status = .verified
//            default:
//                self.completion.status = .none
//            }
//
//            // Set Date field
//            self.completion.date = (data["date"] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: TimeInterval(exactly: 0.0)!)
//            self.completion.user_id = data["user_id"] as? String ?? ""
//            self.completion.activity_ref = data["activity_ref"] as? DocumentReference
//            self.id = doc.documentID
//
//            let activity_data = data["activity_data"] as! [String: Any]
//            title = activity_data["title"] as? String ?? ""
//            instruction = activity_data["instruction"] as? String ?? ""
//            category = activity_data["category"] as? String ?? ""
//            date = (activity_data["date"] as? Timestamp)?.dateValue() ?? Date()
//            let geo = activity_data["location"] as? GeoPoint
//            let name = data["location_name"] as? String ?? ""
//            location = Location(name: name, latitude: geo?.longitude, longitude: geo?.latitude)
//
//        } else {
//            let data = doc.data()!
//
//            title = data["title"] as? String ?? ""
//            instruction = data["instruction"] as? String ?? ""
//            category = data["category"] as? String ?? ""
//            date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
//            if let geo = data["location"] as? GeoPoint {
//                let name = data["location_name"] as? String ?? ""
//                location = Location(name: name, latitude: geo.longitude, longitude: geo.latitude)
//            } else {
//                location = Location()
//            }
//
//            self.id = doc.documentID
//        }
//    }
//
//
//    /// Creates a new activity from the input fields.
//    ///
//    /// - Parameters:s
//    ///   - data: A dictionary of values for the activity's parameters.
//    ///   - status: Enumerated value describing current status.
//    init(data: [String:Any], withStatus status: ActivityStatus = .none) {
//        title = data["title"] as? String ?? ""
//        instruction = data["instruction"] as? String ?? ""
//        date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
//        category = data["category"] as? String ?? ""
//        if let geo = data["location"] as? GeoPoint {
//            let name = data["location_name"] as? String ?? ""
//            location = Location(name: name, latitude: geo.longitude, longitude: geo.latitude)
//        } else {
//            location = Location()
//        }
//
//
//        self.completion = CompletionData()
//        self.completion.date = Date()
//        self.completion.user_id = ""
//        self.completion.status = status
//    }
//
//
//    /// Implemented Equatable function comparing by Firestore activity ID.
//    ///
//    /// - Parameters:
//    ///   - lhs: The first input Activity.
//    ///   - rhs: The second input Activity.
//    /// - Returns: Returns "true" if both Activities have the same path, "false" otherwise.
//    static func == (lhs: Activity, rhs: Activity) -> Bool {
//        var lPath = "activities/\(lhs.id ?? "")"
//        var rPath = "activities/\(rhs.id ?? "")"
//
//        if let left = lhs.completion.activity_ref{
//            lPath = left.path
//        }
//        if let right = rhs.completion.activity_ref{
//            rPath = right.path
//        }
//
//        return lPath == rPath
//    }
//
//
//    /// Implemented Comparable function comparing activities by ID.
//    ///
//    /// - Parameters:
//    ///   - lhs: The first input activity.
//    ///   - rhs: The second input activity.
//    /// - Returns: Returns "true" if the left ID is less than the right ID.
//    static func < (lhs: Activity, rhs: Activity) -> Bool {
//        return lhs.id ?? "" < rhs.id ?? ""
//    }
//
//
//    /// Implemented Comparable function comparing activities by ID.
//    ///
//    /// - Parameters:
//    ///   - lhs: The first input activity
//    ///   - rhs: The second input activity
//    /// - Returns: Returns "true" if the left ID is greater than the right ID.
//    static func > (lhs: Activity, rhs: Activity) -> Bool {
//        return lhs.id ?? "" > rhs.id ?? ""
//    }
//}
