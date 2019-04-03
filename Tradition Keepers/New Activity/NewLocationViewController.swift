//
//  LocationViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/2/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

class NewLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    @IBOutlet var TableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var selectedLocation: Location?
    var searchResults: [Location] = [] {
        didSet {
            TableView.reloadData()
        }
    }
    var allLocations: [Location] = [] {
        didSet {
            searchResults = allLocations
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        FetchLocations()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        TableView.tableHeaderView = searchController.searchBar
        
        TableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(allLocations)
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "LocationCell")
        cell.textLabel?.text = self.searchResults[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocation = searchResults[indexPath.row]
        performSegue(withIdentifier: "UnwindToNewActivity", sender: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            searchResults = allLocations
        } else {
            searchResults = allLocations.filter({ $0.name.lowercased().contains(searchController.searchBar.text?.lowercased() ?? "") })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NewLocationViewController {
    func FetchLocations() {
        var tempLocations: [Location] = []
        Activity.db.collection("locations").getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    let name = doc.get("title") as! String
                    let geo = doc.get("coordinate") as! GeoPoint
                    let coordinate = MKMapPoint(x: geo.longitude, y: geo.latitude)
                    let newLocation = Location(name: name, coordinate: coordinate)
                    tempLocations.append(newLocation)
                }
                self.allLocations = tempLocations
            }
        })
    }
}

struct Location {
    var name: String
    var coordinate: MKMapPoint
}
