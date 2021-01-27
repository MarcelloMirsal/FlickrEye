//
//  FlickrServiceTests.swift
//  FlickrEyeTests
//
//  Created by Marcello Mirsal on 25/01/2021.
//

import XCTest
@testable import FlickrEye
class FlickrServiceTests: XCTestCase {
    
    fileprivate var serviceRouterFake: RouterFake!
    var sut: FlickrService!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = FlickrService()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        if let _ = serviceRouterFake {
            serviceRouterFake.localJSONManager.deleteResponseFile()
        }
    }
    
    
    func testRequestPhotosFeedWithSuccessfulResponse_PhotosFeedShouldBeNotNil() {
        arrangeSutWithFakeRouter(isSuccessfulResponse: true)
        let exp = expectation(description: "testRequestPhotosFeedWithSuccessfulResponse")
        let location = GeoLocation(lat: 48.85, lon: 2.29)
        
        sut.requestPhotosFeed(at: location) { (photosFeed, serviceError) in
            XCTAssertNil(serviceError)
            XCTAssertNotNil(photosFeed)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequestPhotosFeedWithFailedResponse_PhotosFeedShouldBeNil() {
        arrangeSutWithFakeRouter(isSuccessfulResponse: false)
        let exp = expectation(description: "testRequestPhotosFeedWithFailedResponse")
        let location = GeoLocation(lat: 48.85, lon: 2.29)
        
        sut.requestPhotosFeed(at: location) { (photosFeed, serviceError) in
            XCTAssertNotNil(serviceError)
            XCTAssertNil(photosFeed)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func arrangeSutWithFakeRouter(isSuccessfulResponse: Bool) {
        serviceRouterFake = RouterFake()
        let jsonResponse = isSuccessfulResponse ? successfulRequestResponse : failedRequestResponse
        serviceRouterFake.localJSONManager.write(jsonString: jsonResponse)
        sut = .init(router: serviceRouterFake)
    }
}

// MARK:- Test Doubles
fileprivate class RouterFake: FlickrService.Router {
    let localJSONManager = LocalJSONResponseManager.shared
    override func requestForPhotosFeed(atLat lat: Double, atlon lon: Double) -> URLRequest {
        return URLRequest(url: localJSONManager.localJSONFileURL())
    }
}

// MARK:- Requests responses
extension FlickrServiceTests {
    var successfulRequestResponse: String {
        return """
{
    "photos": {
        "page": 1,
        "pages": 6540,
        "perpage": 3,
        "total": "19618",
        "photo": [
            {
                "id": "50845517887",
                "owner": "50762671@N03",
                "secret": "d51b02cd25",
                "server": "65535",
                "farm": 66,
                "title": "Panthéon, Paris",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0
            },
            {
                "id": "30254798441",
                "owner": "49844949@N06",
                "secret": "c53f01ee05",
                "server": "5538",
                "farm": 6,
                "title": "The nth image.2021",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0
            },
            {
                "id": "50835579202",
                "owner": "129360348@N06",
                "secret": "cea083dd4a",
                "server": "65535",
                "farm": 66,
                "title": "Pink & Green",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0
            }
        ]
    },
    "stat": "ok"
}
"""
    }
    
    var failedRequestResponse: String {
        return """
{
    "photos": {
        "page": 1,
        "pages": 19618,
        "perpage": 1,
        "total": "19618",
        "||photo": [
            {
                "id": "50845517887",
                "|||owner": "50762671@N03"
            }
        ]
    },
    "stat": "ok"
}
"""
    }
}
