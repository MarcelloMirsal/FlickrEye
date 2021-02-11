//
//  NetworkService.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 27/01/2021.
//

import UIKit
import Alamofire
import Kingfisher

protocol NetworkServiceParser {
    var jsonDecoder: JSONDecoder { get set }
    func parse<T: Codable>(objectType: T.Type, from data: Data) throws -> T
}

extension NetworkServiceParser {
    func parse<T: Codable>(objectType: T.Type, from data: Data) throws -> T {
        let codableObjec: T
        do {
            codableObjec = try jsonDecoder.decode(objectType, from: data)
        }
        catch {
            throw NetworkServiceError.jsonDecodingFailure
        }
        return codableObjec
    }
}


protocol NetworkServiceProtocol {
    var parser: NetworkServiceParser { get set }
    func request<T: Codable>(objectType: T.Type, urlRequest: URLRequest, response: @escaping (T?, NetworkServiceError?) -> ())
    func requestImage(urlRequest: URLRequest, cache: ImageCache?, response: @escaping (UIImage?, NetworkServiceError?) -> () )
}

extension NetworkServiceProtocol {
    
    func request<T: Codable>(objectType: T.Type, urlRequest: URLRequest, response: @escaping (T?, NetworkServiceError?) -> () ) {
        AF.request(urlRequest).validate().responseJSON { (jsonDataResponse) in
            if let error = jsonDataResponse.error {
                let networkRequestError = AFErrorAdapter(aferror: error).getNetworkRequestError()
                response(nil, .badNetworkRequest(networkRequestError) )
                return
            }
            guard let data = jsonDataResponse.data else {
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
    
    func requestImage(urlRequest: URLRequest, cache: ImageCache? = nil, response: @escaping (UIImage?, NetworkServiceError?) -> () ) {
        let imageRequestOptions: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.targetCache(cache ?? ImageCache.default)]
        
        KingfisherManager.shared.retrieveImage(with: urlRequest.url!, options: imageRequestOptions) { (result) in
            guard let image: UIImage = try? result.get().image else {
                response(nil, .imageLoadingFailure)
                return
            }
            response(image, nil)
        }
    }
}
