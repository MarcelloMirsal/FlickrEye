//
//  FlickrPhoto.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 26/01/2021.
//

import Foundation


struct FlickrPhoto {
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
    }
}

struct FlickrPhotosFeed {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photos: FlickrPhoto
}

extension FlickrPhotosFeed {
    struct DOT: Codable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: String
        let photos: [FlickrPhoto.DTO]
        
        enum Custom: String, CodingKey {
            case page, pages, perpage, total
            case photosFeedResponse = "photos"
            case photos = "photo"
        }
        
        init(from decoder: Decoder) throws {
            let responseContainer = try decoder.container(keyedBy: Custom.self)
            let responseFeed = try responseContainer.nestedContainer(keyedBy: Custom.self, forKey: .photosFeedResponse)
            page = try responseFeed.decode(Int.self, forKey: .page)
            pages = try responseFeed.decode(Int.self, forKey: .pages)
            perpage = try responseFeed.decode(Int.self, forKey: .perpage)
            total = try responseFeed.decode(String.self, forKey: .total)
            photos = try responseFeed.decode([FlickrPhoto.DTO].self, forKey: .photos)
        }
    }
}
