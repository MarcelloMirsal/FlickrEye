//
//  FlickrServiceTests.swift
//  FlickrEyeTests
//
//  Created by Marcello Mirsal on 25/01/2021.
//

import XCTest
@testable import FlickrEye
class FlickrServiceTests: XCTestCase {
    
    var sut: FlickrService!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = FlickrService()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testRequestPhotosAtLocationSuccessfully_PhotosFeedShouldBeNotNil() {
        let exp = expectation(description: "testRequestPhotosAtLocationSuccessfully")
        let location = GeoLocation(lat: 48.85, lon: 2.29)
        sut.requestPhotosFeed(at: location) { (photosFeed, serviceError) in
            XCTAssertNil(serviceError)
            XCTAssertNotNil(photosFeed)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRequestPhotosAtLocationFailure_PhotosFeedShouldBeNil() {
        let exp = expectation(description: "testRequestPhotosAtLocationFailure")
        let location = GeoLocation(lat: 48.85, lon: 2.29)
        sut.requestPhotosFeed(at: location) { (photosFeed, serviceError) in
            XCTAssertNil(serviceError)
            XCTAssertNotNil(photosFeed)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
}


class RouterTests: XCTestCase {
    var sut: FlickrService.Router!
    override func setUp() {
        sut = .init()
    }
    
    func testBaseURLComponents_ShouldBeEqualTypicalBaseURLComponents() {
        let typicalBaseURLComponents = URLComponents(string: "https://www.flickr.com/services/rest/?format=json&nojsoncallback=1&method=flickr.photos.search&api_key=2d8d865ab3daa6e8c5a14d33e733f56a&text=-&per_page=20")!
        let baseURLComponenets = sut.baseURLComponents
        XCTAssertEqual(typicalBaseURLComponents.scheme, NetworkConstants.scheme.rawValue)
        XCTAssertEqual(typicalBaseURLComponents.host, baseURLComponenets.host)
        XCTAssertEqual(typicalBaseURLComponents.path, baseURLComponenets.path)
        XCTAssertEqual(typicalBaseURLComponents.queryItems, baseURLComponenets.queryItems)
    }
    
    func testRequestForPhotos_RequestShouldContainPassedLonLatParams() {
        let lat = 10.1
        let lon = 21.2
        
        let urlComponents = URLComponents(url: sut.requestForPhotosFeed(atLat: lat, atlon: lon).url!, resolvingAgainstBaseURL: true)!
        
        let hasLat = urlComponents.queryItems!.contains(.init(name: FlickrService.Router.Params.lat.rawValue, value: "\(lat)"))
        let hasLon = urlComponents.queryItems!.contains(.init(name: FlickrService.Router.Params.lon.rawValue, value: "\(lon)"))
        
        XCTAssertTrue(hasLat)
        XCTAssertTrue(hasLon)
    }
}

