//
//  FlickrServiceRouter.swift
//  FlickrEyeTests
//
//  Created by Marcello Mirsal on 27/01/2021.
//

import XCTest
@testable import FlickrEye
class FlickrServiceRouterTests: XCTestCase {
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
