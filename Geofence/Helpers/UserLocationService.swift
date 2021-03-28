//
//  UserLocationService.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 28/03/2021.
//

import Foundation
import CoreLocation

enum UserLocationError: Error {
    case monitorFailedForUnknownRegion
    case monitorFailedForRegion(identifier: String)
    case locationManagerFailed(error: Error)
}

typealias UserLocationCompletionBlock = (_ authorized: Bool?, _ enterRegion: Bool?, _ error: UserLocationError?) -> Void

class UserLocationService: NSObject {
    var provider: UserLocationProvider
    var locationCompletionBlock: UserLocationCompletionBlock
    
    init(provider: UserLocationProvider, locationCompletionBlock: @escaping UserLocationCompletionBlock) {
        self.provider = provider
        self.locationCompletionBlock = locationCompletionBlock
        super.init()
        self.provider.delegate = self
    }
}

extension UserLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        let authorized = status == .authorizedWhenInUse || status == .authorizedAlways
        
        locationCompletionBlock(authorized, nil, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            locationCompletionBlock(nil, true, nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            locationCompletionBlock(nil, false, nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        guard let region = region else {
            locationCompletionBlock(nil, nil, .monitorFailedForUnknownRegion)
            return
        }
        locationCompletionBlock(nil, nil, .monitorFailedForRegion(identifier: region.identifier))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletionBlock(nil, nil, .locationManagerFailed(error: error))
    }
}
