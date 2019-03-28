//
//  Category.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/28/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
import Firebase

class Category: Equatable, Comparable {
    static var onUpdate: ((_ categories: [Category])-> ())?
    static var Categories: [Category] = [] {
        didSet {
            onUpdate?(Categories)
        }
    }
    
    var name: String
    var count: Int
    
    var data: [String:String] {
        return ["title":name]
    }
    
    init() {
        name = "General"
        count = 0
    }
    
    init(fromDoc: DocumentSnapshot) {
        name = fromDoc.get("title") as! String
        count = fromDoc.get("count") as! Int
    }
    
    init(withName: String, ofCount: Int = 0) {
        name = withName
        count = ofCount
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
    
    static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.name < rhs.name
    }
}
