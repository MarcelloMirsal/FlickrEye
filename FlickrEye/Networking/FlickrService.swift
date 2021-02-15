//
//  FlickrService.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 25/01/2021.
//


import UIKit
import SDWebImage

final class FlickrService: NetworkServiceProtocol {
    typealias FlickrPhotosFeedResponse = (FlickrPhotosFeed.DOT?, NetworkServiceError?) -> ()
    
    var parser: NetworkServiceParser = Parser()
    private let router: Router
    
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
        // base url used to reduce URLComponents setup requirements
        final private let photosFeedBaseURLString = "https://www.flickr.com/services/rest/?format=json&nojsoncallback=1"
        final private let photoBaseURLString = "https://live.staticflickr.com"
        
        func requestForPhotosFeed(atLat lat: Double, atlon lon: Double) -> URLRequest {
            var photosRequestComponents = URLComponents(string: photosFeedBaseURLString)!
            photosRequestComponents.queryItems?.append(contentsOf: [
                .init(name: Params.lat.rawValue, value: String(lat)),
                .init(name: Params.lon.rawValue, value: String(lon)),
                .init(name: Params.method.rawValue, value: Constants.searchMethod.rawValue),
                .init(name: Params.apiKey.rawValue, value: Constants.apiKey.rawValue),
                .init(name: Params.photosPerPage.rawValue, value: Constants.perPageResults.rawValue),
                .init(name: Params.text.rawValue, value: "-")
            ])
            return URLRequest(url: photosRequestComponents.url!)
        }
        
        func requestForPhoto(serverId: String, photoId: String, secret: String) -> URLRequest {
            let path = photoPath(serverId: serverId, photoId: photoId, secret: secret)
            var photoRequestComponents = URLComponents(string: photoBaseURLString)!
            photoRequestComponents.path = path
            return URLRequest(url: photoRequestComponents.url!)
        }
        
        final func photoPath(serverId: String, photoId: String, secret: String) -> String {
            // serverId/photoId_secret_q.jpg
            let photoId = "/\(photoId)_\(secret)_\(Constants.photoQuality.rawValue)"
            let photoPath = "/\(serverId)" + photoId
            return photoPath
        }
        
    }
}


extension FlickrService.Router {
    enum Constants: String, CaseIterable {
        case apiKey = "2d8d865ab3daa6e8c5a14d33e733f56a"
        case host = "www.flickr.com"
        case photosHost = "live.staticflickr.com"
        case path = "/services/rest/"
        case searchMethod = "flickr.photos.search"
        case perPageResults = "30"
        case photoQuality = "q.jpg" // q.jpg = a thumbnail photo, size 150px.
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
