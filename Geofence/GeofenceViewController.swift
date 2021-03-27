//
//  GeofenceViewController.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 24/03/2021.
//

import Foundation
import UIKit
import MapKit

enum PreferencesKeys: String {
  case savedItems
}

class GeofenceViewController: UIViewController {
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
    
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
      mapView.zoomToLocation(mapView.userLocation.location)
    }
    
    func startMonitoring(geotification: Geotification) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(
                withTitle: "Error",
                message: "Geofencing is not supported on this device!")
            return
        }
        
        let fenceRegion = geotification.region
        
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard
                let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geotification.identifier
            else { continue }
            
            locationManager.stopMonitoring(for: circularRegion)
        }
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
