//
//  NetworkService.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 27/01/2021.
//

import Foundation
import Alamofire

protocol NetworkServiceParser {
    var jsonDecoder: JSONDecoder { get set }
    func parse<T: Codable>(objectType: T.Type, from data: Data) throws -> T
}

extension NetworkServiceParser {
    func parse<T: Codable>(objectType: T.Type, from data: Data) throws -> T {
        do {
            let codableObject = try jsonDecoder.decode(objectType, from: data)
            return codableObject
        } catch {
            throw NetworkServiceError.jsonDecodingFailure
        }
    }
}


protocol NetworkServiceProtocol {
    var parser: NetworkServiceParser { get set }
    func request<T: Codable>(objectType: T.Type, urlRequest: URLRequest, response: @escaping (T?, NetworkServiceError?) -> ())
}

extension NetworkServiceProtocol {
    
    func request<T: Codable>(objectType: T.Type, urlRequest: URLRequest, response: @escaping (T?, NetworkServiceError?) -> () ) {
        AF.request(urlRequest).validate().responseJSON { (dataResponse) in
            if let error = dataResponse.error {
                let networkRequestError = AFErrorAdapter(aferror: error).getNetworkRequestError()
                response(nil, .badNetworkRequest(networkRequestError) )
                return
            }
            guard let data = dataResponse.data else {
                response(nil, .noDataFound)
                return
            }
            do {
                let codableObject = try parser.parse(objectType: objectType, from: data)
                response(codableObject, nil)
            } catch {
                response(nil, .jsonDecodingFailure)
            }
        }
    }
}
