//
//  Category.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/28/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
import Firebase

struct Category {
    var id: String
    var name: String
    var count: Int
    
    var dictionary: [String: Any] {
        return [
            "title": name
        ]
    }
}

extension Category: DocumentSerializable {
    static var categories: [String: Category] = [
        "general": Category(id: "", name: "General", count: 0)
    ]
    
    init() {
        id = ""
        name = "New Category"
        count = 0
    }
    
    init?(dictionary: [String : Any], id: String) {
        guard let name = dictionary["title"] as? String
            else { return nil }
        
        let count = dictionary["count"] as? Int ?? 0
        self.init(id: id, name: name, count: count)
    }
}


//class Category: Equatable, Comparable {
//    static var onUpdate: ((_ categories: [String:Category])-> ())?
//    static var Categories: [String:Category] = [:] {
//        didSet {
//            onUpdate?(Categories)
//        }
//    }
//
//
//
//    init() {
//        name = "General"
//        count = 0
//    }
//
//    init(fromDoc: DocumentSnapshot) {
//        name = fromDoc.get("title") as! String
//        count = fromDoc.get("count") as? Int ?? 0
//    }
//
//    init(withName: String, ofCount: Int = 0) {
//        name = withName
//        count = ofCount
//    }
//
//    static func == (lhs: Category, rhs: Category) -> Bool {
//        return lhs.name == rhs.name
//    }
//
//    static func < (lhs: Category, rhs: Category) -> Bool {
//        return lhs.name < rhs.name
//    }
//}
