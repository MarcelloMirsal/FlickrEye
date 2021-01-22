//
//  NetworkRequest.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 22/01/2021.
//

import Foundation

protocol URLRequestConvertible {
    func urlRequest() -> URLRequest?
}

protocol NetworkRequestProtocol: URLRequestConvertible {
    var method: HTTPMethod { get set }
    var host: String { get set }
    var path: String { get set }
    var params: [String: Any ] { get set }
    var headers: [String : Any] { get set }
}

struct NetworkRequest: NetworkRequestProtocol {
    var method: HTTPMethod
    var host: String
    var path: String
    var params: [String : Any]
    var headers: [String : Any]
}

// MARK:- Default Implementation
extension NetworkRequestProtocol {
    func urlRequest() -> URLRequest? {
        return .init(url: setupURL() )
    }
    
    fileprivate func setupURL() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = NetworkConstants.scheme.rawValue
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems(from: params)
        return urlComponents.url!
    }
    
    fileprivate func queryItems(from dict: [String : Any] ) -> [URLQueryItem] {
        return dict.map { (param) -> URLQueryItem in
            .init(name: param.key, value: stringParameterValues(from: param.value))
        }
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
            return "UndefinedDataTypesValue"
        }
    }
}

