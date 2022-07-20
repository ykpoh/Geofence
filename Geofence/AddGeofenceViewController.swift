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
    @IBOutlet weak var mapView: MKMapView!
    
    weak var delegate: AddGeofenceViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *) {
            let apperance = UINavigationBarAppearance()
            apperance.configureWithDefaultBackground()
            apperance.backgroundColor = UIColor("#00B0FE")
            apperance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = apperance
            navigationController?.navigationBar.scrollEdgeAppearance = apperance
        }
        else {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController?.navigationBar.barTintColor = UIColor("#00B0FE")
        }
        
        navigationItem.rightBarButtonItems = [addButton, zoomButton]
        addButton.isEnabled = false
        tableView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor("#1C1C1E") : .white
    }
    
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        let wifiSet = !(wifiNameTextField.text?.isEmpty ?? true)
        let radiusSet = !(radiusTextField.text?.isEmpty ?? true)
        addButton.isEnabled = wifiSet && radiusSet
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onAdd(sender: AnyObject) {
        let coordinate = mapView.centerCoordinate
        let wifiName = wifiNameTextField.text ?? ""
        let radius = Double(radiusTextField.text ?? "") ?? 0
        let identifier = NSUUID().uuidString
        let geotification = Geotification(
            coordinate: coordinate,
            radius: radius,
            identifier: identifier,
            wifiName: wifiName)
        delegate?.addGeofenceViewController(self, didAddGeofence: geotification)
    }
    
    @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToLocation(mapView.userLocation.location)
    }
}
