//
//  PlaceMarkDetailsViewController.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 13/01/2021.
//

import UIKit
import CoreLocation
import MapKit


class PlaceMarkDetailsViewController: UIViewController, LoadingIndicator {
    enum PresentationMode { case dismissed, presented }
    enum Section { case main }
    static func initiate(with mapView: MKMapView?) -> PlaceMarkDetailsViewController {
        let placeMarkDetailsVC = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaceMarkDetailsViewController") as! PlaceMarkDetailsViewController)
        placeMarkDetailsVC.mapView = mapView
        return placeMarkDetailsVC
    }
    
    @IBOutlet weak var detailsBlurView: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    lazy var feedLoadingIndicatorView: LoadingIndicatorView = {
        .init(reloadingSelector: #selector(handleReloadingAction), target: self)
    }()
    
    var feedPhotoCellRegistration: UICollectionView.CellRegistration<FeedPhotoCell, FlickrPhoto>!
    var headerViewRegistration: UICollectionView.SupplementaryRegistration<PlaceMarkDetailsHeaderView>!
    var diffableDataSource: UICollectionViewDiffableDataSource<Section, FlickrPhoto>!
    
    let viewModel = PlaceMarkDetailsViewModel()
    weak var mapView: MKMapView?
    var currentPlaceMarkLocation: CLLocation!
    
    var countryDescription: String = ""
    var detailsDescription: String = ""
    
    lazy var dismissYLocation: CGFloat = 0
    lazy var presentYLocation: CGFloat = 0
    var currentFraction: CGFloat = 0
    var animator: UIViewPropertyAnimator!
    var currentPresentation: PresentationMode = .dismissed
    
    
    
    // MARK:- View's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPanGesture()
        setupDetailsBlurViewLayer()
        setupCollectionView()
        setupCollectionViewRegistration()
        setupCollectionViewDataSource()
        setupFeedLoadinIndicator()
        setViewAtDismissPresentation()
        setupAnimator()
    }
    
    // MARK:- setup methods
    func setViewAtDismissPresentation() {
        presentYLocation = view.frame.origin.y
        dismissYLocation = view.frame.height * 0.65
        currentPresentation = .dismissed
        view.frame.origin.y = dismissYLocation
    }
    
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        let collectionViewLayout = PlaceMarkDetailsLayout().photosFeedLayout()
        collectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
        
        let headerViewNib = UINib(nibName: "PlaceMarkDetailsHeaderView", bundle: nil)
        collectionView.register(headerViewNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaceMarkDetailsHeaderView.id)
    }
    
    func setupCollectionViewRegistration() {
        let feedPhotoCellNib = UINib(nibName: "FeedPhotoCell", bundle: nil)
        feedPhotoCellRegistration = UICollectionView.CellRegistration<FeedPhotoCell, FlickrPhoto>.init(cellNib: feedPhotoCellNib) { [weak self] (cell, indexPath, flickrPhoto) in
            cell.backgroundColor = UIColor(displayP3Red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
            self?.viewModel.request(flickrPhoto: flickrPhoto, completion: { (flickrPhotoImage) in
                DispatchQueue.main.async {
                    cell.imageView.image = flickrPhotoImage
                }
            })
        }
        
        let headerViewNib = UINib(nibName: "PlaceMarkDetailsHeaderView", bundle: nil)
        headerViewRegistration =  UICollectionView.SupplementaryRegistration<PlaceMarkDetailsHeaderView>.init(supplementaryNib: headerViewNib, elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            headerView.countryLabel.text = self?.countryDescription
            headerView.detailsLabel.text = self?.detailsDescription
        }
    }
    
    func setupCollectionViewDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Section, FlickrPhoto>(collectionView: collectionView) { [weak self] (collectionView, indexPath, flickrPhoto) -> UICollectionViewCell? in
            guard let feedPhotoCellRegistration = self?.feedPhotoCellRegistration else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: feedPhotoCellRegistration, for: indexPath, item: flickrPhoto)
        }
        
        diffableDataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind,indexPath) -> UICollectionReusableView?  in
            guard let headerViewRegistration = self?.headerViewRegistration else {
                return nil
            }
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerViewRegistration, for: indexPath) 
        }
        collectionView.dataSource = diffableDataSource
        setInitialDataSourceSnpahot()
    }
    
    func setupPanGesture() {
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(handle(panGesture:)) )
    }
    
    func setupDetailsBlurViewLayer() {
        detailsBlurView.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner ]
        detailsBlurView.layer.cornerRadius = 24
        detailsBlurView.layer.masksToBounds = true
    }
    
    // MARK:- Accessors methods
    func setLocationDescriptionInfo(from placeMark: CLPlacemark) {
        let countryInfo = [ placeMark.country, placeMark.administrativeArea , placeMark.locality ].compactMap({$0}).joined(separator: " - ")
        let locationDetailsInfo = [ placeMark.subAdministrativeArea , placeMark.subLocality, placeMark.name ].compactMap({$0}).joined(separator: ", ")
        countryDescription = countryInfo
        detailsDescription = locationDetailsInfo
    }
    
    func setLocationOfflineDescriptionInfo() {
        let info = "(\(currentPlaceMarkLocation.coordinate.latitude)) - (\(currentPlaceMarkLocation.coordinate.longitude))"
        countryDescription = info
        detailsDescription = ""
    }
    
    func set(_ selectedLocation: CLLocation) {
        self.currentPlaceMarkLocation = selectedLocation
    }
    
    // MARK:- Handle reloading action
    @objc
    func handleReloadingAction() {
        feedLoadingIndicatorView.appearance(isHidden: false)
        feedLoadingIndicatorView.setLoadingState(isLoading: true)
        requestLocationInfo()
    }
    
    // MARK:- Location requests
    func requestLocationInfo() {
        setEmptyDataSourceSnapshot()
        guard let _ = currentPlaceMarkLocation else { return }
        viewModel.requestGeoCodingInfo(at: currentPlaceMarkLocation, completion: { (placeMark, errorMessage) in
            guard let placeMark = placeMark, errorMessage == nil else {
                self.requestInfoFailedHandler()
                return
            }
            self.requestInfoSuccessdHandler(placeMark: placeMark)
        })
    }
    
    // MARK:- Location requests handlers
    fileprivate func requestInfoFailedHandler() {
        feedLoadingIndicatorView.appearance(isHidden: false)
        feedLoadingIndicatorView.setLoadingState(isLoading: false)
        setLocationOfflineDescriptionInfo()
        setEmptyDataSourceSnapshot()
    }
    
    fileprivate func requestInfoSuccessdHandler(placeMark: CLPlacemark) {
        feedLoadingIndicatorView.appearance(isHidden: false)
        feedLoadingIndicatorView.setLoadingState(isLoading: true)
        setLocationDescriptionInfo(from: placeMark)
        setEmptyDataSourceSnapshot()
        
        viewModel.requestPhotosFeed(at: currentPlaceMarkLocation) { [weak self] (errorDescription) in
            guard errorDescription == nil else {
                self?.feedLoadingIndicatorView.setLoadingState(isLoading: false)
                return
            }
            self?.setDataSourceSnapshot()
        }
    }
    
    // MARK:- Diffable dataSource methods
    fileprivate func setInitialDataSourceSnpahot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FlickrPhoto>()
        snapshot.appendSections([.main])
        diffableDataSource.apply(snapshot)
    }
    
    /// used to present the header view only when geo-coding info is requested
    fileprivate func setEmptyDataSourceSnapshot() {
        guard !diffableDataSource.snapshot().sectionIdentifiers.isEmpty else {
            setInitialDataSourceSnpahot()
            return
        }
        var currentSnap = diffableDataSource.snapshot()
        currentSnap.deleteItems(viewModel.photosFeed.photos)
        currentSnap.reloadSections([.main])
        diffableDataSource.apply(currentSnap)
    }
    
    fileprivate func setDataSourceSnapshot() {
        feedLoadingIndicatorView.appearance(isHidden: true)
        var snapshot = NSDiffableDataSourceSnapshot<Section, FlickrPhoto>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.photosFeed.photos, toSection: .main)
        diffableDataSource.apply(snapshot)
    }
}

// MARK:- CollectionView Delegate Implementation
extension PlaceMarkDetailsViewController: UICollectionViewDelegate {
    
}

// MARK:- MapViewControllerDelegate Implementation
extension PlaceMarkDetailsViewController:  MapViewControllerDelegate {
    func mapViewController(_ controller: MapViewController, didSelected selectedLocation: CLLocation) {
        set(selectedLocation)
        requestLocationInfo()
    }
}

// MARK:- UIGestureRecognizerDelegate implementation
extension PlaceMarkDetailsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
