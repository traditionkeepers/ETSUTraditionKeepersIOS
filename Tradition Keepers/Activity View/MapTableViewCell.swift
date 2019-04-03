//
//  MapTableViewCell.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {
    @IBOutlet weak var LocationText: UITextField!
    @IBOutlet weak var MapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    var initialLocation: CLLocation = CLLocation()
    var MapPin: ActivityPin = ActivityPin()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func Configure(location: MKMapPoint) {
        initialLocation = CLLocation(latitude: MapPin.coordinate.latitude, longitude: MapPin.coordinate.longitude)
        centerMapOnLocation(location: initialLocation)
        MapView.addAnnotation(MapPin)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        MapView.setRegion(coordinateRegion, animated: true)
    }
}

class ActivityPin: NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    
    var subtitle: String? {
        return locationName
    }
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    override init() {
        self.title = "Super Title"
        self.locationName = "GO BUCS"
        self.coordinate = CLLocationCoordinate2D(latitude: 36.323675, longitude: -82.346314)
    }
}
