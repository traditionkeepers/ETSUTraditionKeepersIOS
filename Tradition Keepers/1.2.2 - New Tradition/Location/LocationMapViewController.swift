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
    @IBOutlet var DropPinButton: UIBarButtonItem!
    @IBOutlet var DropPinInstruction: UILabel!
    
    let initialLocation = CLLocation(latitude: 36.3059, longitude: -82.3650)
    let regionRadius: CLLocationDistance = 1000
    var MapPin: LocationPin? {
        didSet {
            guard let pin = MapPin else { return }
            
            MapView.removeAnnotations(MapView.annotations)
            MapView.addAnnotation(pin)
            MapView.setCenter(pin.coordinate, animated: true)
        }
    }
    
    var titlePrompt: UIAlertController {
        let prompt = UIAlertController(title: "Location Name", message: "Enter the name for the pinned location.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (sender) in
        })
        
        let save = UIAlertAction(title: "Save", style: .default, handler: { (sender) in
            let textField = prompt.textFields![0] as UITextField
            self.MapPin = LocationPin(title: textField.text ?? "", coordinate: self.MapPin!.coordinate)
        })
        
        prompt.addAction(cancel)
        prompt.addAction(save)
        
        prompt.addTextField { (textField) in
            textField.text = self.MapPin?.title ?? nil
            textField.placeholder = "Location Name"
        }
        return prompt
    }
    
    var coordinatePrompt: UIAlertController {
        let prompt = UIAlertController(title: "Location Coordinates", message: "Set the coordinates for the location manually.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (sender) in
        })
        
        let save = UIAlertAction(title: "Save", style: .default, handler: { (sender) in
            var failed = false
            var latitude = 0.0
            var longitude = 0.0
            
            if let lat = Double((prompt.textFields![0] as UITextField).text!) {
                latitude = lat
            } else {
                prompt.textFields![0].setRightViewIcon(icon: .linearIcons(.crossCircle), rightViewMode: .always, textColor: .red, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
                failed = true
            }
            
            if let lon = Double((prompt.textFields![1] as UITextField).text!) {
                longitude = lon
            } else {
                prompt.textFields![1].setRightViewIcon(icon: .linearIcons(.crossCircle), rightViewMode: .always, textColor: .red, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
                failed = true
            }
            
            if failed {
                self.present(self.coordinatePrompt, animated: true)
            } else {
                self.MapPin = LocationPin(title: self.MapPin?.title ?? "", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        })
        
        prompt.addAction(cancel)
        prompt.addAction(save)
        prompt.addTextField { (textField) in
            textField.text = self.MapPin != nil ? String(self.MapPin!.coordinate.latitude) : nil
            textField.placeholder = "Latitude"
            textField.keyboardType = .decimalPad
        }
        
        prompt.addTextField { (textField) in
            textField.text = self.MapPin != nil ? String(self.MapPin!.coordinate.longitude) : nil
            textField.placeholder = "Longitude"
            textField.keyboardType = .decimalPad
        }
        return prompt
    }
    
    @IBAction func DropPinPressed(_ sender: Any) {
        let title = MapPin != nil ? "Edit Location" : "New Location"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let dropPin = UIAlertAction(title: "Drop Pin", style: .default)
        dropPin.setValue(UIImage.init(icon: .linearIcons(.mapMarker), size:CGSize(width: 25, height: 25)), forKey: "image")
        let location = UIAlertAction(title: "Current Location", style: .default) { (action) in
            //Get current location
        }
        location.setValue(UIImage.init(icon: .linearIcons(.location), size: CGSize(width: 25, height: 25)), forKey: "image")
        
        let coordinate = UIAlertAction(title: "Enter Coordinates", style: .default) { (action) in
            // Alert to enter coordinates
            self.present(self.coordinatePrompt, animated: true)
        }
        coordinate.setValue(UIImage.init(icon: .linearIcons(.earth), size: CGSize(width: 25, height: 25)), forKey: "image")
        
        alert.addAction(dropPin)
        alert.addAction(location)
        alert.addAction(coordinate)
        
        if MapPin != nil {
            let title = UIAlertAction(title: "Edit Title", style: .default, handler: { (alert) in
                // Show Alert to edit location
                self.present(self.titlePrompt, animated: true)
            })
            title.setValue(UIImage.init(icon: .linearIcons(.tag), size: CGSize(width: 25, height: 25)), forKey: "image")
            alert.addAction(title)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func handleLongPress(_ sender : UIGestureRecognizer) {
        if sender.state != .began { return }
        
        let touchPoint = sender.location(in: MapView)
        let touchMapCoordinate = MapView.convert(touchPoint, toCoordinateFrom: MapView)
        
        let pin = LocationPin(title: MapPin?.title ?? "", coordinate: touchMapCoordinate)
        
        if pin.title!.isEmpty {
            self.present(titlePrompt, animated: true, completion: nil)
        }
        
        MapPin = pin
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        DropPinButton.setIcon(icon: .linearIcons(.mapMarker), iconSize: 20)
        DropPinButton.setIcon(icon: .linearIcons(.mapMarker), iconSize: 25, color: UIColor(named: "ETSU GOLD")!)
        Configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let rootVC = navigationController?.topViewController as? NewLocationViewController else {
            return
        }
        
        if MapPin != nil {
            print("Adding")
            rootVC.allLocations.append(Location(name: MapPin!.title ?? "", coordinate: MapPin!.point))
        }
    }
    
    func Configure() {
        centerMapOnLocation(location: initialLocation)
        MapView.showsUserLocation = true
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
    var point: CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
    
    
}
