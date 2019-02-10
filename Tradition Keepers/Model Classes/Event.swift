//
//  Event.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/9/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation

/// Class object for managing an event
class Event : Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        if lhs.name != rhs.name {
            return false
        }
        
        if lhs.description != rhs.description {
            return false
        }
        
        if lhs.icon != rhs.icon {
            return false
        }
        
        if lhs.category != rhs.category {
            return false
        }
        
        return true
    }
    
    var name: String = ""
    var description: String
    var icon: String
    var dateTime: Date
    var category: EventType
    
    /// Constructor - Creates a new Event object with input parameters
    ///
    /// Usage:
    ///
    ///     init(withName: "Football Game", ofDescription: "Attend one home football game", withIcon: "🏈")
    ///
    /// - Parameter withName: The name of the event.
    /// - Parameter ofDescription: The description for the event.
    /// - Parameter withIcon: The icon for the event.
    /// - Parameter atTime: The Date/Time object for the event.
    /// - Parameter ofType: The category of the event.
    init(withName: String, ofDescription: String, withIcon: String, atTime: Date = Date.init(), ofType: EventType = EventType.General) {
        self.name = withName
        self.description = ofDescription
        self.icon = withIcon
        self.dateTime = atTime
        self.category = ofType
    }
    
}

/// Enumerated type for specifing event types
enum EventType {
    case General
    case Athletics
    case Arts
}
