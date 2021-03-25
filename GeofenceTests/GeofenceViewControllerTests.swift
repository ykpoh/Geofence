//
//  GeofenceViewControllerTests.swift
//  GeofenceTests
//
//  Created by Poh  Yung Kien on 24/03/2021.
//

import XCTest
@testable import Geofence

class GeofenceViewControllerTests: XCTestCase {
    var sut: GeofenceViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = GeofenceViewController.instanceFromStoryboard()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
}
