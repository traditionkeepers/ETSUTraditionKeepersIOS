//
//  Features.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/17/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
class Permission {
    // View Controller Access
    static var dashboard = false
    static var traditions = false
    static var submissions = false
    static var users = false
    static var settings = false
    
    // Tradition Access
    static var allowCreation = false
    static var allowEditing = false
    static var allowDeletion = false
    
    // Submission Access
    static var allowSubmission = false
    static var allowApproval = false
    
    static func configure(user: UserPermission) {
        print("Configuring feature permission for \(user)")
        switch user {
        case .none:
            // Tabs
            dashboard = false
            traditions = false
            submissions = false
            users = false
            settings = true
        
            // Traditions
            allowCreation = false
            allowEditing = false
            allowDeletion = false
        
            // Submissions
            allowSubmission = false
            allowApproval = false
    
        case .user:
            // Tabs
            dashboard = true
            traditions = true
            submissions = false
            users = false
            settings = true
        
            // Traditions
            allowCreation = false
            allowEditing = false
            allowDeletion = false
        
            // Submissions
            allowSubmission = true
            allowApproval = false
    
        case .staff:
            // Tabs
            dashboard = true
            traditions = true
            submissions = true
            users = true
            settings = true
        
            // Traditions
            allowCreation = false
            allowEditing = false
            allowDeletion = false
        
            // Submissions
            allowSubmission = false
            allowApproval = true
    
        case .admin:
            // Tabs
            dashboard = true
            traditions = true
            submissions = true
            users = true
            settings = true
        
            // Traditions
            allowCreation = true
            allowEditing = true
            allowDeletion = true
        
            // Submissions
            allowSubmission = false
            allowApproval = true
        }
    }
}
