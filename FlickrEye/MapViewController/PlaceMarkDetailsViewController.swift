//
//  PlaceMarkDetailsViewController.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 13/01/2021.
//

import UIKit
import CoreLocation


class PlaceMarkDetailsViewController: UIViewController {
    enum PresentationMode {
        case dismissed, presented
    }
    
    @IBOutlet weak var detailsBlurView: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    var countryDescription: String = "Current User Location"
    var detailsDescription: String = "Sub-description"
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setViewAtDismissPresentation()
        setupAnimator()
    }
    
    // MARK:- setup methods
    func setViewAtDismissPresentation() {
        presentYLocation = view.frame.origin.y
        dismissYLocation = view.frame.height * 0.85
        currentPresentation = .dismissed
        view.frame.origin.y = dismissYLocation
        
    }
    
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        let collectionViewLayout = PlaceMarkDetailsLayout().photosFeedLayout()
        collectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        let headerViewNib = UINib(nibName: "PlaceMarkDetailsHeaderView", bundle: nil)
        collectionView.register(headerViewNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaceMarkDetailsHeaderView.id)
    }
    
    func setupAnimator() {
        animator = UIViewPropertyAnimator(duration: 0.7, curve: UIView.AnimationCurve.linear  )
        animator.addAnimations {
            self.view.frame.origin.y = self.presentYLocation
        }
        animator.pausesOnCompletion = true
        animator.addObserver(self, forKeyPath: #keyPath(UIViewPropertyAnimator.isRunning), options: [.new], context: nil)
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
    
    func setLocationDescriptionInfo(from placeMark: CLPlacemark) {
        let countryInfo = [ placeMark.country, placeMark.administrativeArea , placeMark.locality ].compactMap({$0}).joined(separator: " - ")
        let locationDetailsInfo = [ placeMark.subAdministrativeArea , placeMark.subLocality, placeMark.name ].compactMap({$0}).joined(separator: ", ")
        countryDescription = countryInfo
        detailsDescription = locationDetailsInfo
    }
    
    // MARK:- handlers
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIViewPropertyAnimator.isRunning){
            // If the animator is paused
            if !animator.isRunning && animator.fractionComplete == 1 {
                animator.isReversed = !animator.isReversed
                self.currentPresentation = animator.isReversed ? .presented : .dismissed
                self.collectionView.isScrollEnabled = animator.isReversed
                currentFraction = 0
            }
        }
    }
    
}

// MARK:- Animation section
extension PlaceMarkDetailsViewController {
    
    @objc
    func handle(panGesture: UIPanGestureRecognizer) {
        let direction: CGFloat = animator.isReversed ? -1 : 1
        let translation = panGesture.translation(in: view).y
        let fraction = translation / ( -dismissYLocation ) * direction
        
        // to avoid animation and let collectionView scrolls down
        if currentPresentation == .presented && collectionView.contentOffset.y > 0 {
            return
        }
        // stop collectionView Scrolling and begin dismissing animation
        else if currentPresentation == .presented && translation > 0 {
            collectionView.isScrollEnabled = false
        }
        
        switch panGesture.state {
        case .began:
            animator.pauseAnimation()
            currentFraction = animator.fractionComplete
        case .changed:
            animator.fractionComplete =  currentFraction + fraction
            scrollCollectionViewWhenAnimationCompleted(fraction: fraction, translation: translation)
        case .ended:
            let velocity = abs(panGesture.velocity(in: view).y)
            
            if velocity > 700 && translation < 0 {
                animator.isReversed = false
            } else if velocity > 700 && translation > 0 {
                animator.isReversed = true
            } else if animator.fractionComplete < 0.15 {
                animator.isReversed = !animator.isReversed
            }
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0.25)
        default:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0.25)
        }
    }
    
    fileprivate func scrollCollectionViewWhenAnimationCompleted(fraction: CGFloat, translation: CGFloat) {
        if currentPresentation == .dismissed && animator.fractionComplete == 1 && translation < 0  {
            let overCompletionFraction = fraction - 1
            let yOffset = overCompletionFraction * view.frame.height
            collectionView.contentOffset.y = yOffset
        }
    }
    
}

extension PlaceMarkDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(displayP3Red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaceMarkDetailsHeaderView.id, for: indexPath) as! PlaceMarkDetailsHeaderView
        
        headerView.countryLabel.text = countryDescription
        headerView.detailsLabel.text = detailsDescription
        return headerView
    }
    
}


// MARK:- UIGestureRecognizerDelegate implementation
extension PlaceMarkDetailsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
