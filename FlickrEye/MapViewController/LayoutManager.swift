//
//  LayoutManager.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 27/01/2021.
//

import UIKit

class PlaceMarkDetailsLayout {
    
    func photosFeedLayout() -> UICollectionViewCompositionalLayout {
        
        let topPhotoItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let topPhotoItem = NSCollectionLayoutItem(layoutSize: topPhotoItemSize)
        
        let topPhotosGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth( (9/16) / 2 ))
        let topPhotosGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topPhotosGroupSize, subitem: topPhotoItem , count: 3)
        
        let bottomLargePhotoItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let bottomLargePhotoItem = NSCollectionLayoutItem(layoutSize: bottomLargePhotoItemSize)
        let bottomLargePhotoGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1)), subitems: [bottomLargePhotoItem])
        
        let bottomSmallPhotoItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2))
        let bottomSmallPhotoItem = NSCollectionLayoutItem(layoutSize: bottomSmallPhotoItemSize)
        
        let bottmSmallPhotosGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1)), subitem: bottomSmallPhotoItem, count: 2)
        
        let bottomItemsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(9 / 16)), subitems: [bottmSmallPhotosGroup, bottomLargePhotoGroup])
        
        let mainFeedGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1000)), subitems: [topPhotosGroup, bottomItemsGroup])
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let sectionHeaderItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: mainFeedGroup)
        section.boundarySupplementaryItems = [sectionHeaderItem]
        return UICollectionViewCompositionalLayout(section: section)
    }
}
