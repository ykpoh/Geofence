//
//  GeofenceViewController.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 24/03/2021.
//

import Foundation
import UIKit
import MapKit
import Network

enum PreferencesKeys: String {
  case savedItems
}

class GeofenceViewController: UIViewController, NetworkCheckObserver {
    @IBOutlet weak var mapView: MKMapView!
    var geotifications: [Geotification] = [] {
        didSet {
            updateStatus()
        }
    }
    var locationService: UserLocationService?
    var locationManagerType: UserLocationProvider.Type?
    lazy var networkCheck = NetworkCheck.sharedInstance()
    var isWithinRegion = false
    var isConnectedToSavedWifi = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        locationService?.provider.requestAlwaysAuthorization()
        loadAllGeotifications()
        networkCheck.addObserver(observer: self)
    }
    
    deinit {
        networkCheck.removeObserver(observer: self)
    }
    
    func initialize(locationManagerType: UserLocationProvider.Type = CLLocationManager.self, locationService: UserLocationService? = nil) {
        self.locationManagerType = locationManagerType
        self.locationService = locationService ?? UserLocationService(provider: CLLocationManager()) { [weak self] (authorized, enterRegion, error) in
            guard let strongSelf = self else { return }
            strongSelf.locationCompletionBlock(authorized, enterRegion, error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGeofence",
           let navigationController = segue.destination as? UINavigationController,
           let addVC = navigationController.viewControllers.first as? AddGeofenceViewController {
            addVC.delegate = self
        }
    }
    
    func statusDidChange(status: NWPath.Status) {
        updateStatus()
    }
    
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToLocation(mapView.userLocation.location)
    }
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        geotifications.removeAll()
        let allGeotifications = Geotification.loadGeotifications()
        allGeotifications.forEach { add($0) }
    }
    
    func saveAllGeotifications() {
        Geotification.saveGeotifications(geotifications)
    }
    
    func startMonitoring(geotification: Geotification) {
        if !(locationManagerType?.isMonitoringAvailable(for: CLCircularRegion.self) ?? true) {
            showAlert(
                withTitle: "Error",
                message: "Geofencing is not supported on this device!")
            return
        }
        
        let fenceRegion = geotification.region
        
        locationService?.provider.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoring(geotification: Geotification) {
        guard let monitoredRegions = locationService?.provider.monitoredRegions else { return }
        for region in monitoredRegions {
            guard
                let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geotification.identifier
            else { continue }
            
            locationService?.provider.stopMonitoring(for: circularRegion)
        }
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(_ geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func remove(_ geotification: Geotification) {
        guard let index = geotifications.firstIndex(of: geotification) else { return }
        geotifications.remove(at: index)
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func updateGeotificationsCount() {
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
    }
    
    func updateStatus() {
        guard !geotifications.isEmpty else {
            updateNavigationBar(title: "Geofence", color: UIColor("#00B0FE"))
            return
        }
        
        if let ssid = SSID.getWiFiSSID(), geotifications.contains(where: { $0.wifiName == ssid }) {
            isConnectedToSavedWifi = true
        } else {
            isConnectedToSavedWifi = false
        }
        
        if isConnectedToSavedWifi || isWithinRegion {
            updateNavigationBar(title: "INSIDE", color: .green)
        } else {
            updateNavigationBar(title: "OUTSIDE", color: .red)
        }
    }
    
    func updateNavigationBar(title: String, color: UIColor?) {
        self.title = title
        navigationController?.navigationBar.barTintColor = color
    }
    
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification) {
        mapView.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude &&
                coord.longitude == geotification.coordinate.longitude &&
                circleOverlay.radius == geotification.radius {
                mapView.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    func locationCompletionBlock(_ authorized: Bool?, _ enterRegion: Bool?, _ error: UserLocationError?) {
        if let authorized = authorized {
            locationDidChangeAuthorizationCompletionBlock(authorized)
        } else if let enterRegion = enterRegion {
            locationCrossRegionCompletionBlock(enterRegion)
        } else if let error = error {
            locationGeneralErrorCompletionBlock(error)
        }
    }
    
    func locationDidChangeAuthorizationCompletionBlock(_ authorized: Bool) {
        mapView.showsUserLocation = authorized
        
        if !authorized {
            let message = """
        Your geofence area is saved but will only be activated once you grant
        Geofence permission to access the device location.
        """
            showAlert(withTitle: "Warning", message: message)
        }
    }
    
    func locationCrossRegionCompletionBlock(_ enterRegion: Bool) {
        isWithinRegion = enterRegion
        updateStatus()
    }
    
    func locationGeneralErrorCompletionBlock(_ error: UserLocationError) {
        switch error {
        case .monitorFailedForUnknownRegion:
            showToast("Monitoring failed for unknown region")
        case .monitorFailedForRegion(let identifier):
            showToast("Monitoring failed for region with identifier: \(identifier)")
        case .locationManagerFailed(let error):
            showToast("Location Manager failed with the following error: \(error)")
        }
    }
}

// MARK: AddGeofenceViewControllerDelegate
extension GeofenceViewController: AddGeofenceViewControllerDelegate {
    func addGeofenceViewController(_ controller: AddGeofenceViewController, didAddGeofence geotification: Geotification) {
        controller.dismiss(animated: true, completion: nil)
        
        if let maxRadius = locationService?.provider.maximumRegionMonitoringDistance {
            geotification.clampRadius(maxRadius: maxRadius)
        }
        add(geotification)
        
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
}

// MARK: - MapView Delegate
extension GeofenceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeotification"
        if annotation is Geotification {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        guard let geotification = view.annotation as? Geotification else { return }
        stopMonitoring(geotification: geotification)
        remove(geotification)
        saveAllGeotifications()
    }
}
