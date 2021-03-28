//
//  UserLocationProvider.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 28/03/2021.
//

import Foundation
import CoreLocation

protocol UserLocationProvider {
    var delegate: CLLocationManagerDelegate? { get set }
    var monitoredRegions: Set<CLRegion> { get }
    var maximumRegionMonitoringDistance: CLLocationDistance { get }
    func requestAlwaysAuthorization()
    func startMonitoring(for region: CLRegion)
    func stopMonitoring(for region: CLRegion)
    func startUpdatingLocation()
    static func isMonitoringAvailable(for regionClass: AnyClass) -> Bool
}

extension CLLocationManager: UserLocationProvider {}
