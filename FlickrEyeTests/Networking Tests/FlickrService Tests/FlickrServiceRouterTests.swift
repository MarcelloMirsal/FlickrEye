//
//  FlickrServiceRouterTests.swift
//  FlickrEyeTests
//
//  Created by Marcello Mirsal on 27/01/2021.
//

import XCTest
@testable import FlickrEye

class FlickrServiceRouterTests: XCTestCase {
    let Constants = FlickrService.Router.Constants.self
    let Params = FlickrService.Router.Constants.self
    var sut: FlickrService.Router!
    
    let lat = 53.486530011539585
    let lon = -2.2573716726007778
    lazy var idealPhotosFeedURLString = "https://www.flickr.com/services/rest/?format=json&nojsoncallback=1&method=flickr.photos.search&api_key=2d8d865ab3daa6e8c5a14d33e733f56a&text=-&per_page=\(Constants.perPageResults.rawValue)&lat=\(lat)&lon=\(lon)"
    
    override func setUp() {
        sut = .init()
    }
    
    func testRequestForPhotosFeed_ShouleReturnURLComponentsEqualTo() {
        let idealPhotoFeedURLComponents = URLComponents(string: idealPhotosFeedURLString)!
        let photosFeedURL = sut.requestForPhotosFeed(atLat: lat, atlon: lon).url!
        let photosFeedURLCompoents = URLComponents(url: photosFeedURL, resolvingAgainstBaseURL: false)!
        
        XCTAssertEqual(photosFeedURLCompoents.scheme, NetworkConstants.scheme.rawValue)
        XCTAssertEqual(photosFeedURLCompoents.host, Constants.host.rawValue)
        XCTAssertEqual(photosFeedURLCompoents.path, Constants.path.rawValue)
        for queryItem in photosFeedURLCompoents.queryItems! {
            XCTAssertTrue( idealPhotoFeedURLComponents.queryItems!.contains(queryItem) )
        }
    }
    
    func testPhotoURL_ShouldReturnValidFlickrPhotoURL() {
        // ideal photo url structure
        // "https://live.staticflickr.com/{server-id}/{id}_{secret}_{size-suffix}.jpg"
        let serverId = "65535", photoId = "50904123771", secret = "68c6ed1b55"
        let photoRequest = sut.requestForPhoto(serverId: serverId, photoId: photoId, secret: secret)
        let photoURLComponents = URLComponents(url: photoRequest.url!, resolvingAgainstBaseURL: true)!
        XCTAssertEqual(photoURLComponents.scheme, NetworkConstants.scheme.rawValue)
        XCTAssertEqual(photoURLComponents.host, Constants.photosHost.rawValue)
        XCTAssertEqual(photoURLComponents.path, sut.photoPath(serverId: serverId, photoId: photoId, secret: secret))
    }
}


// MARK:- Constants & Params test
extension FlickrServiceRouterTests {
    
    func testConstatnPhotosHost_ShouldBeEqualToFlickrPhotosHost() {
        let flickrPhotosHost = "live.staticflickr.com"
        XCTAssertEqual(Constants.photosHost.rawValue, flickrPhotosHost)
    }
    
    func testConstatnPhotoQuality_ShouldBeEqualToFlickrThumbnailQuality() {
        let photoQuality = "q.jpg"
        XCTAssertEqual(Constants.photoQuality.rawValue, photoQuality)
    }
}
