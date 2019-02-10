//
//  MainEventTableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/9/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class MainEventTableViewController: UITableViewController {
    let sections = ["Today", "Tomorrow", "Coming Up"]
    
    var allEvents: [Event] = [
        Event(withName: "Football Game", ofDescription: "Attend one home football game.", withIcon: "🏈", ofType: EventType.Athletics),
        Event(withName: "Art Show", ofDescription: "Attend an art show.", withIcon: "🎨", ofType: EventType.Arts),
        Event(withName: "Concert", ofDescription: "Attend the spring concert.", withIcon: "🎸", atTime: Date(timeIntervalSinceNow: TimeInterval(exactly: 86400)!), ofType: EventType.Arts)
    ]
    
    var todayEvents: [Event] {
        get {
            let cal = Calendar.current
            var today: [Event] = []
            for event in allEvents {
                if cal.isDateInToday(event.dateTime) {
                    today.append(event)
                }
            }
            return today
        }
    }
    
    var tomorrowEvents: [Event] {
        get {
            let cal = Calendar.current
            var tomorrow: [Event] = []
            for event in allEvents {
                if cal.isDateInTomorrow(event.dateTime) {
                    tomorrow.append(event)
                }
            }
            return tomorrow
        }
    }
    
    var users: [String:User] = [
        "default@etsu.edu":User(id: "default@etsu.edu", name: "Default User"),
        "thally@etsu.edu":User(id: "thally@etsu.edu", name: "Ryan Thally", events: [
                Event(withName: "Football Game", ofDescription: "Attend one home football game.", withIcon: "🏈", ofType: EventType.Athletics),
                Event(withName: "Art Show", ofDescription: "Attend an art show.", withIcon: "🎨", ofType: EventType.Arts),
                Event(withName: "Concert", ofDescription: "Attend the spring concert.", withIcon: "🎸", atTime: Date(timeIntervalSinceNow: TimeInterval(exactly: 86400)!), ofType: EventType.Arts)
                ])
    ]
    var currentId: String?
    lazy var currentUser = users[currentId ?? ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows if valid section
        if section == 0 {
            return todayEvents.count
            
        } else if section == 1 {
            return allEvents.count - todayEvents.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainEventCell", for: indexPath) as! MainEventTableViewCell
        var event: Event
        if indexPath.section == 0 {
            event = todayEvents[indexPath.row]
        } else {
            event = tomorrowEvents[indexPath.row] // Get the appropriate event for the given row
        }
        
        let complete = currentUser?.completedEvents.contains(event) ?? false
        
         // Configure the cell...
        cell.update(with: event, isCompleted: complete)
        
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
