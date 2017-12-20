//
//  CategoryCollectionViewController.swift
//  CoinMap
//
//  Created by Lex Leontiev on 15/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit

class CategoryCollectionViewController: UICollectionViewController {
    
    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        categories = CategoryCollection.getItems();
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
            as? CategoryCollectionViewCell else {
                fatalError("The dequeued cell is not an instance of CategoryCollectionViewCell.")
        }
        // Configure the cell
        let category = categories[indexPath.row]
        cell.nameLabel.text = category.name
        cell.icon.image = category.icon
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cat = categories[indexPath.row]
        if cat != nil {
            self.tabBarController?.selectedIndex = 0;
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: AppDelegate.mySpecialNotificationKey),
                object: self,
                userInfo: [
                    "cat": cat.code
                ])
        }
    }
}
