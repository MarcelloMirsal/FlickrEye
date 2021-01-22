//
//  MapViewControllerTests.swift
//  FlickrEyeTests
//
//  Created by Marcello Mirsal on 12/01/2021.
//

import XCTest
@testable import FlickrEye

class MapViewControllerTests: XCTestCase {

    var sut: MapViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController)
        _ = sut.view
    }
    
    // MARK:- IBOutlets tests
    func testMapView_ShouldBeNotNil() {
        XCTAssertNotNil(sut.mapView)
    }
    
    
    // MARK:- Handlers tests
    func testLocationSelectionHandlerForBeganState_SenderShouldBeNotEnabled() {
        let sender = UILongPressGestureRecognizer()
        // simulate tap gesture did begin (Disable the sender)
        sender.state = .began
        sut.locationSelectionHandler(sender)
        XCTAssertFalse(sender.isEnabled)
    }
    
    func testLocationSelectionHandlerForCancelledState_SenderShouldBeEnabled() {
        let sender = UILongPressGestureRecognizer()
        sender.state = .cancelled
        sut.locationSelectionHandler(sender)
        
        XCTAssertTrue(sender.isEnabled)
    }
    
    func testSelectLocationAtCoordinate_() {
        let selectedPoint = CGPoint(x: 10, y: 10)
        let selectedPointAnnotation = sut.selectLocation(at: selectedPoint)
        XCTAssertEqual(sut.mapView.annotations.first?.coordinate, selectedPointAnnotation.coordinate)
    }
    
}
