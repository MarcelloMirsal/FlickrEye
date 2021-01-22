//
//  NetworkConstantsTests.swift
//  StoreBoxTests
//
//  Created by Marcello Mirsal on 27/07/2020.
//  Copyright © 2020 Mohammed Ahmed. All rights reserved.
//

import XCTest
@testable import FlickrEye

class NetworkConstantsTests: XCTestCase {
    func testScheme_ShouldBeEqualToTHTTPS() {
        XCTAssertEqual(NetworkConstants.scheme.rawValue, "https")
    }
}

class HTTPMethodTests: XCTestCase {
    func testGETMethod_ShouldBeEqualToGET() {
        XCTAssertEqual(HTTPMethod.GET.rawValue, "GET")
    }
}
