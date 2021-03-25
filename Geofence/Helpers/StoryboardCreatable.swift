//
//  StoryboardCreatable.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 24/03/2021.
//

import UIKit

protocol StoryboardCreatable: class {
    static var storyboard: UIStoryboard { get }
    static var storyboardBundle: Bundle? { get }
    static var storyboardIdentifier: String { get }
    static var storyboardName: String { get }
    
    static func instanceFromStoryboard() -> Self
}
