//
//  extensions and helpers.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 22/01/2021.
//

import Foundation
extension Dictionary {
    func isEqual(to dict: Dictionary) -> Bool {
        return NSDictionary(dictionary: self).isEqual(to: dict)
    }
}
