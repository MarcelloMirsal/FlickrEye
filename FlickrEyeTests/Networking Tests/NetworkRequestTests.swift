//
//  NetworkRequestTests.swift
//  FlickrEyeTests
//
//  Created by Marcello Mirsal on 22/01/2021.
//

import XCTest
@testable import FlickrEye

class NetworkRequestTests: XCTestCase {
    var sut: NetworkRequestProtocol!
    let paramsDict: [String : Any] = [ "String" : "Value" , "Number" : "10", "Array" : ["1","2"], "ArrayString" : ["A" , "B" , "C" ,"D"] ]
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = NetworkRequest(method: .GET, host: "UnitTest.com", path: "/FlickrEye/Tests", params: paramsDict, headers: [:])
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSutInit_ShouldSetProperties() {
        let method = HTTPMethod.GET, path = "/path", host = "host", params = ["K" : "V" as Any], headers = ["K1" : 10 as Any]
        sut = NetworkRequest(method: method, host: host, path: path, params: params, headers: headers)
        
        XCTAssertEqual(sut.method, method); XCTAssertEqual(sut.path, path); XCTAssertEqual(sut.host, host)
        XCTAssertTrue(sut.params.isEqual(to: params))
        XCTAssertTrue(sut.headers.isEqual(to: headers))
    }
    
    func testURLRequest_ShouldReturnValidURL() {
        /// Should return url equal to (params could be sorted differenatly)
        ///https://UnitTest.com/FlickrEye/Tests?Array=1,2&ArrayString=A,B,C,D&Number=10&String=Value
        
        // taking the Request URL after been configured from SUT properties
        guard let configuredURL = sut.urlRequest()?.url else { XCTFail("No Valid URL") ; return }
        let configuredURLComponents = URLComponents(url: configuredURL, resolvingAgainstBaseURL: true)!
        let passedQueryItems = sut.params.map({ URLQueryItem(name: $0.key, value: stringParameterValues(from: $0.value)) })
        
        XCTAssertEqual(configuredURLComponents.scheme, NetworkConstants.scheme.rawValue)
        XCTAssertEqual(configuredURLComponents.host, sut.host)
        XCTAssertEqual(configuredURLComponents.path, sut.path)
        XCTAssertEqual(configuredURLComponents.queryItems, passedQueryItems)
    }
    
    func testURLRequestWithUndefinedParamValue_ShouldReturnNotNilURL() {
        // the URL should be tolerate with Undefined DataTypes Value
        sut.params = [ "UndefinedDataTypesKey": 10 ]
        let configuredURL = sut.urlRequest()?.url
        XCTAssertNotNil(configuredURL)
    }
    
    
    
    
    
    fileprivate func stringParameterValues(from paramValue: Any) -> String {
        switch paramValue {
        case is String:
            return paramValue as! String
        case is [String]:
            let paramValues = paramValue as! [String]
            return String(paramValues.reduce("", {$0 + $1 + ","}).dropLast())
        default:
            print("WARNING: paramValue is not catched")
            return "UndefinedParameterDataType"
        }
    }
}
