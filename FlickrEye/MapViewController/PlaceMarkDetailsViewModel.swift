//
//  PlaceMarkDetailsViewModel.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 03/02/2021.
//

import CoreLocation
import UIKit

class PlaceMarkDetailsViewModel {
    private let gecoder = CLGeocoder()
    private let flickrService: FlickrService
    private(set) var photosFeed = FlickrPhotosFeed(page: 0, pages: 0, perpage: 0, total: 0, photos: [])
    
    init(flickrService: FlickrService = FlickrService() ){
        self.flickrService = flickrService
    }
    
    // MARK:- Accessors
    fileprivate func set(_ photosFeed: FlickrPhotosFeed) {
        self.photosFeed = photosFeed
    }
    
    func requestGeoCodingInfo(at location: CLLocation, completion: @escaping (CLPlacemark?, String? ) -> () ) {
        gecoder.reverseGeocodeLocation(location) { (placeMarks, requestError) in
            guard requestError == nil, let placeMark = placeMarks?.first else {
                completion(nil, requestError?.localizedDescription)
                return
            }
            completion(placeMark, nil)
        }
    }
    
    func requestPhotosFeed(at location: CLLocation, completion: @escaping (String?) -> () ) {
        flickrService.requestPhotosFeed(at: location.geoLocation()) { (photosFeedDTO, serviceError) in
            guard let photosFeed = photosFeedDTO?.map(), serviceError == nil else {
                completion(serviceError?.localizedDescription)
                return
            }
            self.set(photosFeed)
            completion(nil)
        }
    }
    
    func request(flickrPhoto: FlickrPhoto, completion: @escaping (UIImage?) -> () ) {
        flickrService.request(flickrPhoto: flickrPhoto) { (image) in
            completion(image)
        }
    }
}
