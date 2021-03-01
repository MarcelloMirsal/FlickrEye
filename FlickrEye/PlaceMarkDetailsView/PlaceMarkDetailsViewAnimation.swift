//
//  PlaceMarkDetailsViewAnimation.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 06/02/2021.
//

import UIKit

// MARK:- Animation section
extension PlaceMarkDetailsViewController {
    
    func setupAnimator() {
        animator = UIViewPropertyAnimator(duration: 0.7, curve: UIView.AnimationCurve.linear  )
        animator.addAnimations {
            self.view.transform = .identity
        }
        animator.pausesOnCompletion = true
        animator.pauseAnimation()
        animator.addObserver(self, forKeyPath: #keyPath(UIViewPropertyAnimator.isRunning), options: [.new], context: nil)
    }
    
    // MARK:- animation state observation handlers
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIViewPropertyAnimator.isRunning){
            // If the animator is paused
            if !animator.isRunning && animator.fractionComplete == 1 {
                animator.isReversed = !animator.isReversed
                currentPresentation = animator.isReversed ? .presented : .dismissed
                collectionView.isScrollEnabled = animator.isReversed
                currentFraction = 0
            }
        }
    }
    
    @objc
    func handle(panGesture: UIPanGestureRecognizer) {
        //        animator is nil if device is an ipad
        guard let animator = self.animator else { return }
        let direction: CGFloat = animator.isReversed ? -1 : 1
        let translation = panGesture.translation(in: view).y
        let fraction = translation / ( -dismissYLocation ) * direction
        // to avoid animation and let collectionView scrolls down
        if currentPresentation == .presented && collectionView.contentOffset.y > 0 && panGesture.view === collectionView  {
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
            animator.fractionComplete =  currentFraction + fraction
        case .changed:
            animator.fractionComplete =  currentFraction + fraction
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
}
