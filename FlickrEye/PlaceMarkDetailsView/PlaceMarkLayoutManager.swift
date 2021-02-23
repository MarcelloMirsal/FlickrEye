//
//  PlaceMarkLayoutManager.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 27/01/2021.
//

import UIKit

class PlaceMarkDetailsLayout {
    
    func photosFeedLayout() -> UICollectionViewCompositionalLayout {
        
        let topPhotoItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1)))
        topPhotoItem.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
        let topPhotosGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3)), subitem: topPhotoItem, count: 3)
        
        let largePhotoItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1)))
        largePhotoItem.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let smallPhotoItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
        smallPhotoItem.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let smallPhotosGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1)), subitem: smallPhotoItem, count: 2)
        
        let largeAndSmallphotosGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(2/3)), subitems: [largePhotoItem, smallPhotosGroup])
        
        let mainGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1000)), subitems: [ topPhotosGroup, largeAndSmallphotosGroup ])
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let sectionHeaderItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let sectionFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let sectionFooterItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionFooterSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        
        let section = NSCollectionLayoutSection(group: mainGroup)
        section.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
        section.boundarySupplementaryItems = [sectionHeaderItem, sectionFooterItem]
        return UICollectionViewCompositionalLayout(section: section)
    }
}
