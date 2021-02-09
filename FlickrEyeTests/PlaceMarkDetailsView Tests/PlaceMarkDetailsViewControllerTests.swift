//
//  PlaceMarkDetailsViewControllerTests.swift
//  FlickrEyeTests
//
//  Created by Marcello Mirsal on 22/01/2021.
//

import XCTest
@testable import FlickrEye

class PlaceMarkDetailsViewControllerTests: XCTestCase {
    var sut: PlaceMarkDetailsViewController!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaceMarkDetailsViewController") as? PlaceMarkDetailsViewController
        _ = sut.view
        sut.viewDidAppear(false)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPanGestureDelegate_ShouldRecognizeSimultaneouslyWithOtherGestureRecognizer() {
        let isRecognizeSimultaneous = sut.gestureRecognizer(sut.panGesture, shouldRecognizeSimultaneouslyWith: sut.collectionView.panGestureRecognizer)
        XCTAssertTrue(isRecognizeSimultaneous)
    }
    
    
}
