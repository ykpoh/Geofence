//
//  AddGeofenceViewController.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 27/03/2021.
//

import UIKit
import MapKit

protocol AddGeofenceViewControllerDelegate: class {
    func addGeofenceViewController(_ controller: AddGeofenceViewController, didAddGeofence: Geotification)
}

class AddGeofenceViewController: UITableViewController {
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var zoomButton: UIBarButtonItem!
    @IBOutlet weak var wifiNameTextField: UITextField!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    weak var delegate: AddGeofenceViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [addButton, zoomButton]
        addButton.isEnabled = false
    }
    
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        let wifiSet = !(wifiNameTextField.text?.isEmpty ?? true)
        let radiusSet = !(radiusTextField.text?.isEmpty ?? true)
        let noteSet = !(noteTextField.text?.isEmpty ?? true)
        addButton.isEnabled = wifiSet && radiusSet && noteSet
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onAdd(sender: AnyObject) {
        let coordinate = mapView.centerCoordinate
        let wifiName = wifiNameTextField.text ?? ""
        let radius = Double(radiusTextField.text ?? "") ?? 0
        let identifier = NSUUID().uuidString
        let note = noteTextField.text ?? ""
        let geotification = Geotification(
            coordinate: coordinate,
            radius: radius,
            identifier: identifier,
            note: note,
            wifiName: wifiName)
        delegate?.addGeofenceViewController(self, didAddGeofence: geotification)
    }
    
    @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToLocation(mapView.userLocation.location)
    }
}
