//
//  Extensions and helpers.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 13/01/2021.
//

import MapKit

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension JSONDecoder {
    convenience init(convertStrategy: JSONDecoder.KeyDecodingStrategy) {
        self.init()
        self.keyDecodingStrategy = convertStrategy
    }
}
