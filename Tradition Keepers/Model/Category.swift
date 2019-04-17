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
