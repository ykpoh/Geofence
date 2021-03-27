//
//  Geotification.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 27/03/2021.
//

import UIKit
import MapKit
import CoreLocation

class Geotification: NSObject, Codable, MKAnnotation {
    enum EventType: String {
        case onEntry = "On Entry"
        case onExit = "On Exit"
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, radius, identifier, note, wifiName
    }
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var wifiName: String
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .naturalScale
        let radiusString = formatter.string(from: Measurement(value: radius, unit: UnitLength.meters))
        return "Radius: \(radiusString)"
    }
    
    func clampRadius(maxRadius: CLLocationDegrees) {
        radius = min(radius, maxRadius)
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, wifiName: String) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.wifiName = wifiName
    }
    
    // MARK: Codable
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        radius = try values.decode(Double.self, forKey: .radius)
        identifier = try values.decode(String.self, forKey: .identifier)
        note = try values.decode(String.self, forKey: .note)
        wifiName = try  values.decode(String.self, forKey: .wifiName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(radius, forKey: .radius)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(note, forKey: .note)
        try container.encode(wifiName, forKey: .wifiName)
    }
}

extension Geotification {
    public class func allGeotifications() -> [Geotification] {
        guard let savedData = UserDefaults.standard.data(forKey: PreferencesKeys.savedItems.rawValue) else { return [] }
        let decoder = JSONDecoder()
        if let savedGeotifications = try? decoder.decode(Array.self, from: savedData) as [Geotification] {
            return savedGeotifications
        }
        return []
    }
}


// MARK: - Notification Region
extension Geotification {
    var region: CLCircularRegion {
        let region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: identifier)
        
        return region
    }
}
