//
//  FlickrPhoto.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 26/01/2021.
//

import Foundation


struct Pagination {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
}

struct FlickrPhoto: Hashable {
    let uuid = UUID()
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
}

extension FlickrPhoto {
    struct DTO: Codable {
        let id: String
        let owner: String
        let secret: String
        let server: String
        let farm: Int
        let title: String
        
        func map() -> FlickrPhoto {
            return .init(id: id, owner: owner, secret: secret, server: server, farm: farm, title: title)
        }
    }
}

struct FlickrPhotosFeed {
    let pagination: Pagination
    let photos: [FlickrPhoto]
}

extension FlickrPhotosFeed {
    struct DOT: Codable {
        let page: Int
        let pages: Int
        let perPage: Int
        let total: String
        let photos: [FlickrPhoto.DTO]
        
        enum Custom: String, CodingKey {
            case page, pages, perPage = "perpage", total
            case photosFeedResponse = "photos"
            case photos = "photo"
        }
        
        init(from decoder: Decoder) throws {
            let responseContainer = try decoder.container(keyedBy: Custom.self)
            let responseFeed = try responseContainer.nestedContainer(keyedBy: Custom.self, forKey: .photosFeedResponse)
            page = try responseFeed.decode(Int.self, forKey: .page)
            pages = try responseFeed.decode(Int.self, forKey: .pages)
            perPage = try responseFeed.decode(Int.self, forKey: .perPage)
            total = try responseFeed.decode(String.self, forKey: .total)
            photos = try responseFeed.decode([FlickrPhoto.DTO].self, forKey: .photos)
        }
        
        func map() -> FlickrPhotosFeed {
            let feedPhotos = self.photos.map({$0.map()})
            let pagination = Pagination(page: page, pages: pages, perPage: perPage, total: Int(total)! )
            let mappedObject = FlickrPhotosFeed(pagination: pagination, photos: feedPhotos)
            return mappedObject
        }
    }
}
