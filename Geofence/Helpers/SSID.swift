//
//  SSID.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 27/03/2021.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

protocol SSIDProvider {
    static func getWiFiSSID() -> String?
}

class SSID: SSIDProvider {
    class func getWiFiSSID() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
}
