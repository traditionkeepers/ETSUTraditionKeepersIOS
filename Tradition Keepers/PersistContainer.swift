//
//  PersistContainer.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
import CoreData

class PersistContainer {
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(name: String) {
        self.container = NSPersistentContainer(name: name)
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
}
