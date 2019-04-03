//
//  LocationMapViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/3/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationMapViewController: UIViewController {
    
    @IBOutlet var MapView: MKMapView!
    @IBOutlet var LongPressGesture: UILongPressGestureRecognizer!
    
    let initialLocation = CLLocation(latitude: 36.3059, longitude: -82.3650)
    let regionRadius: CLLocationDistance = 1000
    var MapPin: LocationPin?
    
    @IBAction func handleLongPress(_ sender : UIGestureRecognizer) {
        if sender.state != .began { return }
        
        let touchPoint = sender.location(in: MapView)
        let touchMapCoordinate = MapView.convert(touchPoint, toCoordinateFrom: MapView)
        MapPin = LocationPin(title: "", coordinate: touchMapCoordinate)
        
        let prompt = UIAlertController(title: "Location Name", message: "Enter the name for the pinned location.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (sender) in
        })
        
        let save = UIAlertAction(title: "Save", style: .default, handler: { (sender) in
            let textField = prompt.textFields![0] as UITextField
            self.MapPin!.title = textField.text
            self.MapView.removeAnnotations(self.MapView.annotations)
            self.MapView.addAnnotation(self.MapPin!)
        })
        
        prompt.addAction(cancel)
        prompt.addAction(save)
        
        prompt.addTextField { (textField) in
            textField.placeholder = "Location Name"
        }
        
        self.present(prompt, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let rootVC = navigationController?.topViewController as? NewLocationViewController else {
            return
        }
        
        print("Adding")
        rootVC.allLocations.append(Location(name: MapPin!.title ?? "", coordinate: MapPin!.point))
    }
    
    func Configure(location: MKMapPoint) {
        centerMapOnLocation(location: initialLocation)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        MapView.setRegion(coordinateRegion, animated: true)
    }
    

    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
 */
}

class LocationPin: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var point: MKMapPoint {
        return MKMapPoint(x: coordinate.longitude, y: coordinate.latitude)
    }
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
    
    
}
