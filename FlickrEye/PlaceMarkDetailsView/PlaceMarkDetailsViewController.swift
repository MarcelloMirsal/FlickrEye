//
//  PlaceMarkDetailsViewController.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 13/01/2021.
//

import UIKit
import CoreLocation
import MapKit


class PlaceMarkDetailsViewController: UIViewController {
    enum PresentationMode { case dismissed, presented }
    typealias Section = PlaceMarkDetailsViewModel.Section
    
    static func initiate(with mapViewController: MapViewController) -> PlaceMarkDetailsViewController {
        let placeMarkDetailsVC = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaceMarkDetailsViewController") as! PlaceMarkDetailsViewController)
        mapViewController.mapSelectionDelegate = placeMarkDetailsVC
        return placeMarkDetailsVC
    }
    
    @IBOutlet weak var detailsBlurView: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var viewPanGesture: UIPanGestureRecognizer!
    
    @IBOutlet var draggingPanGesture: UIPanGestureRecognizer!
    
    
    @IBOutlet weak var draggingIndicatorView: UIView!
    var feedPhotoCellRegistration: UICollectionView.CellRegistration<FeedPhotoCell, FlickrPhoto>!
    var headerViewRegistration: UICollectionView.SupplementaryRegistration<PlaceMarkDetailsHeaderView>!
    var footerViewRegistration: UICollectionView.SupplementaryRegistration<PaginationLoadingIndicatorView>!
    
    let viewModel = PlaceMarkDetailsViewModel()
    
    lazy var dismissYLocation: CGFloat = 0
    var currentFraction: CGFloat = 0
    var animator: UIViewPropertyAnimator!
    var currentPresentation: PresentationMode = .dismissed
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        animator.removeObserver(self, forKeyPath: #keyPath(UIViewPropertyAnimator.isRunning), context: nil)
    }
    
    // MARK:- View's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPanGestures()
        setupDetailsBlurViewLayer()
        setupCollectionView()
        setupCollectionViewRegistration()
        setupCollectionViewDataSource()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        traitCollectionDidChange(nil)
        setupApplicationStateObservation()
    }
    
    // MARK:- setup methods
    
    /// this method set an observer to the app state to setup the animation again when application enters the foreground state
    fileprivate func setupApplicationStateObservation() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleApplicationStateChange), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func setViewAtDismissPresentation() {
        collectionView.isScrollEnabled = false
        currentPresentation = .dismissed
        dismissYLocation = view.frame.height * 0.7
        view.transform = .init(translationX: 0, y: dismissYLocation)
    }
    
    func setViewAtPresentationForIpad() {
        collectionView.isScrollEnabled = true
        currentPresentation = .presented
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let hSizeClass = traitCollection.horizontalSizeClass
        let vSizeClass = traitCollection.verticalSizeClass
        
        if traitCollection.userInterfaceIdiom == .pad && hSizeClass == .regular && vSizeClass == .regular  {
            animator?.stopAnimation(false)
            animator?.finishAnimation(at: .end)
            setViewAtPresentationForIpad()
            view.transform = .identity
            animator = nil
        } else {
            animator?.stopAnimation(false)
            animator?.finishAnimation(at: .start)
            setViewAtDismissPresentation()
            setupAnimator()
        }
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
            weak var weakImageViewRef = cell.imageView
            self?.viewModel.request(flickrPhoto: flickrPhoto, imageView: weakImageViewRef)
        }
        
        let headerViewNib = UINib(nibName: "PlaceMarkDetailsHeaderView", bundle: nil)
        headerViewRegistration =  UICollectionView.SupplementaryRegistration<PlaceMarkDetailsHeaderView>.init(supplementaryNib: headerViewNib, elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            headerView.countryLabel.text = self?.viewModel.countryDescription
            headerView.detailsLabel.text = self?.viewModel.detailsDescription
        }
        
        footerViewRegistration = UICollectionView.SupplementaryRegistration<PaginationLoadingIndicatorView>(elementKind: UICollectionView.elementKindSectionFooter, handler: { [weak self] (paginationFooterView, kind, indexPath) in
            guard let strongSelf = self else { return }
            paginationFooterView.loadingIndicatorView.setAction(target: strongSelf, reloadingSelector: #selector(strongSelf.handleReloadingAction))
            paginationFooterView.loadingIndicatorView.set(isLoading: false, isHidden: true)
        })
        
        
    }
    
    func setupCollectionViewDataSource() {
        let diffableDataSource = UICollectionViewDiffableDataSource<Section, FlickrPhoto>(collectionView: collectionView) { [weak self] (collectionView, indexPath, flickrPhoto) -> UICollectionViewCell? in
            guard let feedPhotoCellRegistration = self?.feedPhotoCellRegistration else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: feedPhotoCellRegistration, for: indexPath, item: flickrPhoto)
        }
        
        diffableDataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind,indexPath) -> UICollectionReusableView?  in
            
            guard let headerViewRegistration = self?.headerViewRegistration, let footerViewRegistration = self?.footerViewRegistration else {
                return nil
            }
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerViewRegistration, for: indexPath)
            } else if elementKind == UICollectionView.elementKindSectionFooter {
                return collectionView.dequeueConfiguredReusableSupplementary(using: footerViewRegistration, for: indexPath)
            } else {
                return nil
            }
        }
        collectionView.dataSource = diffableDataSource
        viewModel.set(viewDataSource: diffableDataSource)
    }
    
    func setupPanGestures() {
        viewPanGesture.delegate = self
        draggingPanGesture.delegate = self
        viewPanGesture.addTarget(self, action: #selector(handle(panGesture:)) )
        draggingPanGesture.addTarget(self, action: #selector(handle(panGesture:)))
    }
    
    func setupDetailsBlurViewLayer() {
        detailsBlurView.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner ]
        detailsBlurView.layer.cornerRadius = 24
        detailsBlurView.layer.masksToBounds = true
    }
    
    // MARK:- Handle reloading action
    @objc
    func handleReloadingAction() {
        updatePaginationLoadingFooter(isLoading: true)
        if viewModel.viewDataSource.snapshot().itemIdentifiers.isEmpty {
            requestLocationInfo()
        } else {
            requestPhotosFeedNextPage()
        }
    }
    
    // MARK:- Photos feed Request
    func requestPhotosFeed() {
        viewModel.requestPhotosFeed { [weak self] (errorDescription) in
            guard errorDescription == nil else {
                self?.updatePaginationLoadingFooter(isLoading: false)
                return
            }
        }
    }
    
    func requestPhotosFeedNextPage() {
        viewModel.requestPhotosFeedNextPage { (errorDescription) in
            self.updatePaginationLoadingFooter(isLoading: errorDescription == nil)
        }
    }
    
    // MARK:- Location info request
    func requestLocationInfo() {
        viewModel.setLocationDescriptionsToLoading()
        viewModel.setEmptyDataSourceSnapshot()
        updatePaginationLoadingFooter(isLoading: true)
        viewModel.requestGeoCodingInfo { [weak self] (errorMessage) in
            guard errorMessage == nil else {
                self?.requestInfoFailedHandler()
                return
            }
            self?.requestInfoSuccessHandler()
        }
    }
    
    // MARK:- Location info requests handlers
    fileprivate func requestInfoFailedHandler() {
        viewModel.setEmptyDataSourceSnapshot()
        updatePaginationLoadingFooter(isLoading: false)
    }
    
    fileprivate func requestInfoSuccessHandler() {
        viewModel.setEmptyDataSourceSnapshot()
        requestPhotosFeed()
    }
}

// MARK:- CollectionView Delegate Implementation
extension PlaceMarkDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == UICollectionView.elementKindSectionFooter else { return }
        let paginationFooterView = view as! PaginationLoadingIndicatorView
        let canLoadNextPage = viewModel.canLoadNextPage()
        paginationFooterView.loadingIndicatorView.set(isLoading: canLoadNextPage, isHidden: !canLoadNextPage)
        requestPhotosFeedNextPage()
    }
    
    func updatePaginationLoadingFooter(isLoading: Bool) {
        let paginationFooterView = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter).first as? PaginationLoadingIndicatorView
        paginationFooterView?.loadingIndicatorView.set(isLoading: isLoading)
    }
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
        return gestureRecognizer.view === collectionView
    }
}
