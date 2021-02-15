//
//  PhotosRepository.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 15/02/2021.
//

import UIKit

protocol PhotosRepositoryProtocol {
    func loadPhoto(url: URL, toImageView imageView: UIImageView?)
}

/// Repository
class PhotosRepository: PhotosRepositoryProtocol {
    // recommended for setting up dequeued cells, to prevent cells from rendering wrong photo
    func loadPhoto(url: URL, toImageView imageView: UIImageView?) {
        imageView?.sd_setImage(with: url, completed: nil)
    }
}
