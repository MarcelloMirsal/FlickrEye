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
    typealias Section = PlaceMarkDetailsViewModel.Section
    
    static func initiate(with mapViewController: MapViewController) -> PlaceMarkDetailsViewController {
        let placeMarkDetailsVC = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaceMarkDetailsViewController") as! PlaceMarkDetailsViewController)
        mapViewController.mapSelectionDelegate = placeMarkDetailsVC
        placeMarkDetailsVC.mapView = mapViewController.mapView
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
    
    let viewModel = PlaceMarkDetailsViewModel()
    weak var mapView: MKMapView?
    
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
            cell.imageView.image = nil
            cell.backgroundColor = UIColor(displayP3Red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
            self?.viewModel.request(flickrPhoto: flickrPhoto, completion: { (image) in
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            })
        }
        
        let headerViewNib = UINib(nibName: "PlaceMarkDetailsHeaderView", bundle: nil)
        headerViewRegistration =  UICollectionView.SupplementaryRegistration<PlaceMarkDetailsHeaderView>.init(supplementaryNib: headerViewNib, elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            headerView.countryLabel.text = self?.viewModel.countryDescription
            headerView.detailsLabel.text = self?.viewModel.detailsDescription
        }
    }
    
    func setupCollectionViewDataSource() {
        let diffableDataSource = UICollectionViewDiffableDataSource<Section, FlickrPhoto>(collectionView: collectionView) { [weak self] (collectionView, indexPath, flickrPhoto) -> UICollectionViewCell? in
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
        viewModel.set(viewDataSource: diffableDataSource)
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
    
    // MARK:- Handle reloading action
    @objc
    func handleReloadingAction() {
        feedLoadingIndicatorView.set(isLoading: true)
        requestLocationInfo()
    }
    
    // MARK:- Location requests
    func requestLocationInfo() {
        viewModel.setLocationDescriptionsToLoading()
        viewModel.setEmptyDataSourceSnapshot()
        feedLoadingIndicatorView.set(isLoading: true)
        viewModel.requestGeoCodingInfo { [weak self] (placeMark, errorMessage) in
            guard let placeMark = placeMark, errorMessage == nil else {
                self?.requestInfoFailedHandler()
                return
            }
            self?.requestInfoSuccessdHandler(placeMark: placeMark)
        }
    }
    
    // MARK:- Location requests handlers
    fileprivate func requestInfoFailedHandler() {
        feedLoadingIndicatorView.set(isLoading: false)
        viewModel.setLocationDescriptionsWithCoordinateInfo()
        viewModel.setEmptyDataSourceSnapshot()
    }
    
    fileprivate func requestInfoSuccessdHandler(placeMark: CLPlacemark) {
        feedLoadingIndicatorView.set(isLoading: true)
        viewModel.setLocationDescriptionInfo(from: placeMark)
        viewModel.setEmptyDataSourceSnapshot()
        viewModel.requestPhotosFeed { [weak self] (errorDescription) in
            guard errorDescription == nil else {
                self?.feedLoadingIndicatorView.set(isLoading: false)
                return
            }
            self?.feedLoadingIndicatorView.set(isLoading: false, isHidden: true)
        }
    }
    
}

// MARK:- CollectionView Delegate Implementation
extension PlaceMarkDetailsViewController: UICollectionViewDelegate {
    
}

// MARK:- MapViewControllerDelegate Implementation
extension PlaceMarkDetailsViewController:  MapViewControllerDelegate {
    func mapViewController(_ controller: MapViewController, didSelected selectedLocation: CLLocation) {
        viewModel.set(selectedLocation)
        requestLocationInfo()
    }
}

// MARK:- UIGestureRecognizerDelegate implementation
extension PlaceMarkDetailsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
