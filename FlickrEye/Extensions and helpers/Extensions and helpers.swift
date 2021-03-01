//
//  Extensions and helpers.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 13/01/2021.
//

import MapKit
import CoreLocation

extension UIAlertController {
    static func build(withMessage message: String, title: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        return alertController
    }
}


extension CLLocation {
    func geoLocation() -> GeoLocation {
        return .init(lat: coordinate.latitude, lon: coordinate.longitude)
    }
}

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
