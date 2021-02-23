//
//  NetworkConstants.swift
//  StoreBox
//
//  Created by Marcello Mirsal on 27/07/2020.
//  Copyright © 2020 Mohammed Ahmed. All rights reserved.
//

import Foundation
import Alamofire

enum HTTPMethod: String {
    case GET
}

enum NetworkConstants: String {
    case scheme = "https"
}


enum NetworkServiceError: Error, Equatable {
    case badNetworkRequest(NetworkRequestError)
    case jsonDecodingFailure
    case noDataFound
    case imageLoadingFailure
    var localizedDescription: String {
        switch self {
        case .badNetworkRequest(let requestError):
            return requestError.localizedDescription
        case .jsonDecodingFailure:
            return "parsing failed, please check the JSON response and the object codable keys"
        case .noDataFound:
            return "No data found, the json response could be empty."
        case .imageLoadingFailure:
            return "image loading failure, check network or URL."
        }
    }
}


enum NetworkRequestError: Error {
    case badRequest // OR missing headers like auth
    case timeout
    case noInternetConnection
    case unspecified
    
    var localizedDescription: String {
        switch self {
        case .badRequest:
            return "No data found"
        case .timeout:
            return "Request timeout, please try again"
        case .noInternetConnection:
            return "No internet connection"
        case .unspecified:
            return "unspecified error"
        }
    }
}




class AFErrorAdapter {
    let aferror: AFError
    init(aferror: AFError) {
        self.aferror = aferror
    }
    
    func getNetworkRequestError() -> NetworkRequestError {
        let unSpecifiedErrorStatusCode = 0
        if aferror.responseCode == nil { return .noInternetConnection }
        switch aferror {
        case .sessionTaskFailed(let error as NSError):
            let statusCode = error.code
            return networkRequestError(from: statusCode)
        case .responseValidationFailed(let failureReason):
            let statusCode = responseStatusCode(from: failureReason)
            return networkRequestError(from: statusCode ?? unSpecifiedErrorStatusCode )
        default:
            return networkRequestError(from: unSpecifiedErrorStatusCode )
        }
    }
    
    private func networkRequestError(from statusCode: Int) -> NetworkRequestError {
        switch statusCode {
        case 400:
            return .badRequest
        case -1001:
            return .timeout
        case -1009:
            return .noInternetConnection
        default:
            return .unspecified
        }
    }
    
    private func responseStatusCode(from responseFailureReason: AFError.ResponseValidationFailureReason) -> Int? {
        switch responseFailureReason {
        case .unacceptableStatusCode(let responseStatusCode):
            return responseStatusCode
        default:
            return nil
        }
    }
}
