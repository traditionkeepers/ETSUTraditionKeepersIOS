//
//  LocationViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/2/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    
    @IBOutlet var EnableButton: UIButton!
    
    @IBAction func EnableButtonPressed(_ sender: Any) {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            EnableButton.setTitle("Enable", for: .normal)
            EnableButton.isEnabled = true
        case .authorizedWhenInUse, .authorizedAlways:
            EnableButton.setTitle("All Set!", for: .normal)
            EnableButton.isEnabled = false
            performSegue(withIdentifier: "nextPermission", sender: nil)
        @unknown default:
            fatalError()
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
