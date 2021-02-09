//
//  PlaceMarkDetailsViewModelTests.swift
//  FlickrEyeTests
//
//  Created by Marcello Mirsal on 08/02/2021.
//

import XCTest
import CoreLocation
@testable import FlickrEye
class PlaceMarkDetailsViewModelTests: XCTestCase {

    
    var sut: PlaceMarkDetailsViewModel!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = PlaceMarkDetailsViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK:- Accessors tests
    func testSetViewDataSource_ViewDataSourceShouldBeEqualToNewViewDataSource() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        let newViewDataSource = UICollectionViewDiffableDataSource<PlaceMarkDetailsViewModel.Section, FlickrPhoto>(collectionView: collectionView) { (collectionView, indexPath, flickrPhoto) -> UICollectionViewCell? in
            return nil
        }
        
        sut.set(viewDataSource: newViewDataSource)
        
        XCTAssertEqual(sut.viewDataSource, newViewDataSource)
    }
    
    func testSetLocationDescriptionsWithCoordinateInfo_CountryDescriptionShouldBeNotEmpty() {
        sut.setLocationDescriptionsWithCoordinateInfo()
        
        XCTAssertFalse(sut.countryDescription.isEmpty)
    }
    
    // MARK:- Requests tests
    
    
    
}
