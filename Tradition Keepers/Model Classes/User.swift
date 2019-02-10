//
//  User.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/9/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
class User {
    var id: String
    var name: String
    var completedEvents: [Event]
    var classification: UserClass
    
    init(id: String, name: String, events: [Event] = [], classification: UserClass = .student) {
        self.id = id
        self.name = name
        self.completedEvents = events
        self.classification = classification
    }
}

enum UserClass {
    case student
    case admin
}
