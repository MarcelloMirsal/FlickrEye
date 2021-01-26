//
//  FlickrService.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 25/01/2021.
//


import Foundation
import Alamofire

final class FlickrService: NetworkServiceProtocol {
    var parser: NetworkServiceParser = Parser()
    let router: Router
    typealias FlickrPhotosFeedResponse = (FlickrPhotosFeed.DOT?, NetworkServiceError?) -> ()
    
    init(router: Router = Router()) {
        self.router = router
    }
    
    func requestPhotosFeed(at location: GeoLocation, completion: @escaping FlickrPhotosFeedResponse) {
        let urlRequest = router.requestForPhotosFeed(atLat: location.lat, atlon: location.lon)
        request(objectType: FlickrPhotosFeed.DOT.self, urlRequest: urlRequest) { (photosFeed, serviceError) in
            completion(photosFeed, serviceError)
        }
    }
    
}

extension FlickrService {
    class Parser: NetworkServiceParser {
        var jsonDecoder: JSONDecoder = .init(convertStrategy: .convertFromSnakeCase)
    }
}

extension FlickrService {
    class Router {
        // essential request params with apiKey
        final private let baseURLString = "https://www.flickr.com/services/rest/?format=json&nojsoncallback=1"
        final let baseURLComponents: URLComponents
        
        init() {
            var components = URLComponents(string: baseURLString)!
            components.queryItems?.append(contentsOf: [
                .init(name: Params.method.rawValue, value: Constants.searchMethod.rawValue),
                .init(name: Params.apiKey.rawValue, value: Constants.apiKey.rawValue),
                .init(name: Params.text.rawValue, value: "-"),
                .init(name: Params.photosPerPage.rawValue, value: Constants.perPageResults.rawValue)
            ])
            self.baseURLComponents = components
        }
        
        func requestForPhotosFeed(atLat lat: Double, atlon lon: Double) -> URLRequest {
            var photosRequestComponents = baseURLComponents
            photosRequestComponents.queryItems?.append(contentsOf: [
                .init(name: Params.lat.rawValue, value: String(lat)),
                .init(name: Params.lon.rawValue, value: String(lon)),
            ])
            return URLRequest(url: photosRequestComponents.url!)
        }
    }
}


extension FlickrService.Router {
    enum Constants: String, CaseIterable {
        case host = "www.flickr.com"
        case path = "/services/rest"
        case searchMethod = "flickr.photos.search"
        case perPageResults = "20"
        case apiKey = "2d8d865ab3daa6e8c5a14d33e733f56a"
    }
    
    enum Params: String, CaseIterable {
        case method = "method"
        case apiKey = "api_key"
        case text = "text"
        case lat = "lat"
        case lon = "lon"
        case photosPerPage = "per_page"
    }
}
