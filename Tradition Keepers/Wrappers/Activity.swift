//
//  Activity.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
import Firebase

class Activity {
    
    static var db = User.db
    var data: ActivityData
    var status: ActivityStatus
    
    init()
    {
        data = ActivityData()
        status = .none
    }
    
    init(data: ActivityData, withStatus status: ActivityStatus = .none) {
        self.data = data
        self.status = status
    }
}

enum ActivityStatus: String {
    case none = "Complete"
    case pending = "Pending"
    case verified = "Verified"
}

struct ActivityData {
    var name = "",
    instruction = "",
    category = "",
    date = Date()
}
