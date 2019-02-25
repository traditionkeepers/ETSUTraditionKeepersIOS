//
//  User+CoreDataProperties.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//
//

import Foundation
import CoreData


extension User {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var classification: String?
    @NSManaged public var email: String?
    @NSManaged public var eNumber: String?
    @NSManaged public var first_name: String?
    @NSManaged public var last_name: String?

}
