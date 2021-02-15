//
//  PlaceMarkDetailsViewModel.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 03/02/2021.
//

import CoreLocation
import UIKit
import SDWebImage



class PlaceMarkDetailsViewModel {
    enum Section { case main }
    
    private(set) var countryDescription: String = ""
    private(set) var detailsDescription: String = ""
    private(set) var currentPlaceMarkLocation: CLLocation = .init()
    
    private let geoCoder = CLGeocoder()
    private let flickrService: FlickrService
    private let photosRepository: PhotosRepositoryProtocol = PhotosRepository()
    private(set) var viewDataSource: UICollectionViewDiffableDataSource<Section, FlickrPhoto>!
    
    init(flickrService: FlickrService = FlickrService() ){
        self.flickrService = flickrService
    }
    
    // MARK:- Accessors
    func set(viewDataSource: UICollectionViewDiffableDataSource<Section, FlickrPhoto>) {
        self.viewDataSource = viewDataSource
        setInitialDataSourceSnapshot()
    }
    
    func setLocationDescriptionInfo(from placeMark: CLPlacemark) {
        let countryInfo = [ placeMark.country, placeMark.administrativeArea , placeMark.locality ].compactMap({$0}).joined(separator: " - ")
        let locationDetailsInfo = [ placeMark.subAdministrativeArea , placeMark.subLocality, placeMark.name ].compactMap({$0}).joined(separator: ", ")
        countryDescription = countryInfo
        detailsDescription = locationDetailsInfo
    }
    
    func setLocationDescriptionsWithCoordinateInfo() {
        let info = "(\(currentPlaceMarkLocation.coordinate.latitude)) - (\(currentPlaceMarkLocation.coordinate.longitude))"
        countryDescription = info
        detailsDescription = ""
    }
    
    func setLocationDescriptionsToLoading() {
        countryDescription = "Loading..."
        detailsDescription = ""
    }
    
    func set(_ selectedLocation: CLLocation) {
        self.currentPlaceMarkLocation = selectedLocation
    }
    
    // MARK:- Requests
    func requestGeoCodingInfo(completion: @escaping (CLPlacemark?, String? ) -> () ) {
        geoCoder.reverseGeocodeLocation(currentPlaceMarkLocation) { (placeMarks, requestError) in
            guard requestError == nil, let placeMark = placeMarks?.first else {
                completion(nil, requestError?.localizedDescription)
                return
            }
            completion(placeMark, nil)
        }
    }
    
    func requestPhotosFeed(completion: @escaping (String?) -> () ) {
        flickrService.requestPhotosFeed(at: currentPlaceMarkLocation.geoLocation()) { [weak self] (photosFeedDTO, serviceError) in
            guard let photosFeed = photosFeedDTO?.map(), serviceError == nil else {
                completion(serviceError?.localizedDescription)
                return
            }
            self?.setViewDataSourceSnapshot(from: photosFeed)
            completion(nil)
        }
    }
    
    func request(flickrPhoto: FlickrPhoto, imageView: UIImageView?) {
        let url = FlickrService.Router().requestForPhoto(serverId: flickrPhoto.server, photoId: flickrPhoto.id, secret: flickrPhoto.secret).url!
        photosRepository.loadPhoto(url: url, toImageView: imageView)
    }
    
    // MARK:- Diffable dataSource methods
    func setViewDataSourceSnapshot(from photosFeed: FlickrPhotosFeed) {
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, FlickrPhoto>()
        newSnapshot.appendSections([.main])
        newSnapshot.appendItems(photosFeed.photos, toSection: .main)
        viewDataSource.apply(newSnapshot)
    }
    
    private func setInitialDataSourceSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FlickrPhoto>()
        snapshot.appendSections([.main])
        viewDataSource.apply(snapshot)
    }
    
    /// used to present the header view only when geo-coding info is requested
    func setEmptyDataSourceSnapshot() {
        guard !viewDataSource.snapshot().sectionIdentifiers.isEmpty else {
            setInitialDataSourceSnapshot()
            return
        }
        var currentSnap = viewDataSource.snapshot()
        currentSnap.deleteItems(currentSnap.itemIdentifiers)
        currentSnap.reloadSections([.main])
        viewDataSource.apply(currentSnap)
    }
}
