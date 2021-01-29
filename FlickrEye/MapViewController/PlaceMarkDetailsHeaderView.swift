//
//  PlaceMarkDetailsHeaderView.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 27/01/2021.
//

import UIKit

class PlaceMarkDetailsHeaderView: UICollectionReusableView {
    static let id = "PlaceMarkDetailsHeaderView"
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
