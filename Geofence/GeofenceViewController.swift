//
//  GeofenceViewController.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 24/03/2021.
//

import Foundation
import UIKit
import MapKit

class GeofenceViewController: UIViewController {
    @IBOutlet weak var locateButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    lazy var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1
        locationManager.delegate = self
        // 2
        locationManager.requestAlwaysAuthorization()
        // 3
//        loadAllGeotifications()
    }
}

extension GeofenceViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        let authorized = status == .authorizedWhenInUse || status == .authorizedAlways
        
        mapView.showsUserLocation = authorized
        
        if !authorized {
            let message = """
        Your geofence area is saved but will only be activated once you grant
        Geofence permission to access the device location.
        """
            showAlert(withTitle: "Warning", message: message)
        }
    }
    
}
