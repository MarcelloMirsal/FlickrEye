//
//  PaginationLoadingIndicatorView.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 02/03/2021.
//

import UIKit
class PaginationLoadingIndicatorView: UICollectionReusableView, LoadingIndicator {
    var loadingIndicatorView: LoadingIndicatorView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFeedLoadingIndicator()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    func setupFeedLoadingIndicator() {
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(loadingIndicatorView)
        NSLayoutConstraint.activate([
            loadingIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

