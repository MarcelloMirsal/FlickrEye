//
//  LoadingIndicatorView.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 01/02/2021.
//

import UIKit

/// a protocol to show a loading indicator on ViewController,
protocol LoadingIndicator: UIViewController {
    var feedLoadingIndicatorView: LoadingIndicatorView { get set }
    /// called to add loadingIndicatorView to the view's hierarchy
    func setupFeedLoadingIndicator()
}

extension LoadingIndicator {
    func setupFeedLoadingIndicator() {
        view.addSubview(feedLoadingIndicatorView)
        NSLayoutConstraint.activate([
            feedLoadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            feedLoadingIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            feedLoadingIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}


class LoadingIndicatorView: UIView {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    private let reloadingButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.setTitleColor(.systemGray, for: .normal)
        button.setTitleColor(.systemGray, for: .disabled)
        button.setTitle("Tap here to reload data again.", for: .normal)
        button.setTitle("LOADING...", for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    convenience init(reloadingSelector: Selector, target: Any) {
        self.init(frame: .zero)
        reloadingButton.addTarget(target, action: reloadingSelector, for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    func set(isLoading: Bool, isHidden: Bool = false) {
        setLoadingState(isLoading: isLoading)
        setAppearance(isHidden: isHidden)
    }
    
    private func setLoadingState(isLoading: Bool) {
        reloadingButton.isEnabled = !isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func setAppearance(isHidden: Bool) {
        self.isHidden = isHidden
    }
    
    private func setupViews() {
        addSubview(activityIndicator)
        addSubview(reloadingButton)
        
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            reloadingButton.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 4),
            reloadingButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            reloadingButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            reloadingButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

