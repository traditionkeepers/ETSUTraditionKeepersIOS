//
//  Requirement.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/16/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation

fileprivate enum requirement: String {
    case optional = "optional"
    case required = "required"
}

struct Requirement {
    static var optional: Requirement {
        return requirements["optional"]!
    }
    
    static var required: Requirement {
        return requirements["required"]!
    }
    
    static private(set) var requirements: [String: Requirement] = [
        "optional": Requirement(id: requirement.optional.rawValue, title: "Optional", count: 0),
        "required":Requirement(id: requirement.required.rawValue, title: "Required", count: 0)
    ]
    
    var id: String
    var title: String
    var count: Int
    
    var dictionary: [String: Any] {
        return [
            "title": title
        ]
    }
}

extension Requirement: DocumentSerializable {
    init?(dictionary: [String : Any], id: String) {
        guard let name = dictionary["name"] as? String,
              let count = dictionary["count"] as? Int
        else {
            return nil
        }
        
        self.init(id: id, title: name, count: count)
    }
}
