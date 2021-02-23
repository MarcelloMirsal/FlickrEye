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
    private var isNextPageRequestInProgress = false
    
    private let geoCoder = CLGeocoder()
    private let flickrService: FlickrService
    private let photosRepository: PhotosRepositoryProtocol = PhotosRepository()
    private var pagination: Pagination = .init(page: 1, pages: 1, perPage: 1, total: 0)
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
        print("did set desc info")
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
        countryDescription = "please wait..."
        detailsDescription = ""
    }
    
    func set(_ selectedLocation: CLLocation) {
        self.currentPlaceMarkLocation = selectedLocation
        set(pagination: Pagination.init(page: 1, pages: 1, perPage: 1, total: 0))
    }
    
    func set(pagination: Pagination) {
        self.pagination = pagination
    }
    
    func canLoadNextPage() -> Bool {
        return pagination.page != pagination.pages
    }
    
    // MARK:- Requests
    func requestGeoCodingInfo(completion: @escaping (String?) -> () ) {
        geoCoder.reverseGeocodeLocation(currentPlaceMarkLocation) { (placeMarks, requestError) in
            guard requestError == nil, let placeMark = placeMarks?.first else {
                self.setLocationDescriptionsWithCoordinateInfo()
                completion(requestError?.localizedDescription)
                return
            }
            self.setLocationDescriptionInfo(from: placeMark)
            completion(nil)
        }
    }
    
    func requestPhotosFeed(page: Int = 1, completion: @escaping (String?) -> () ) {
        flickrService.requestPhotosFeed(at: currentPlaceMarkLocation.geoLocation(), page: page) { [weak self] (photosFeedDTO, serviceError) in
            defer { self?.isNextPageRequestInProgress = false }
            guard let photosFeed = photosFeedDTO?.map(), serviceError == nil else {
                completion(serviceError?.localizedDescription)
                return
            }
            self?.set(pagination: photosFeed.pagination)
            self?.appendViewDataSourceItems(from: photosFeed)
            completion(nil)
        }
    }
    
    func requestPhotosFeedNextPage( completion: @escaping (String?) -> () ) {
        guard canLoadNextPage(), isNextPageRequestInProgress == false else {
            return
        }
        print("pass")
        isNextPageRequestInProgress = true
        let page = pagination.page+1
        requestPhotosFeed(page: page, completion: completion)
    }
    
    func request(flickrPhoto: FlickrPhoto, imageView: UIImageView?) {
        let url = FlickrService.Router().requestForPhoto(serverId: flickrPhoto.server, photoId: flickrPhoto.id, secret: flickrPhoto.secret).url!
        photosRepository.loadPhoto(url: url, toImageView: imageView)
    }
    
    // MARK:- Diffable dataSource methods
    func appendViewDataSourceItems(from photosFeed: FlickrPhotosFeed) {
        var snapshot = viewDataSource.snapshot()
        snapshot.appendItems(photosFeed.photos, toSection: .main)
        DispatchQueue.main.async {
            self.viewDataSource.apply(snapshot)
        }
    }
    
    private func setInitialDataSourceSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FlickrPhoto>()
        snapshot.appendSections([.main])
        viewDataSource.apply(snapshot)
    }
    
    /// used to present the header & footer view only when geo-coding info is requested
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



class CancelableOperation: Operation {
    
    init(task: @escaping () -> ()) {
        self.task = task
    }
    
    
    let task: () -> ()
    
    override func main() {
        
    }
    
    override func start() {
        
    }
}
