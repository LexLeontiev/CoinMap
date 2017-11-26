//
//  Category.swift
//  CoinMap
//
//  Created by Lex Leontiev on 15/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit

class Category {
    
    let name: String
    let icon: UIImage!
    
    init(name: String, icon: UIImage!) {
        self.name = name;
        self.icon = icon;
    }
}

class CategoryCollection {
    
    static var items = [Category]()
    
    init() {}
    
    static func getItems() -> Array<Category> {
        if (items.isEmpty) {
            feedCategories()
        }
        return items;
    }
    
    static private func feedCategories() {
        items.append(Category(name:"Cafe", icon: UIImage(named:"cafe")))
        items.append(Category(name:"ATM", icon: UIImage(named:"atm")))
        items.append(Category(name:"Food", icon: UIImage(named:"food")))
        items.append(Category(name:"Cinema", icon: UIImage(named:"cinema")))
        items.append(Category(name:"Shop", icon: UIImage(named:"shop")))
        items.append(Category(name:"Bar", icon: UIImage(named:"bar")))
        items.append(Category(name:"Company", icon: UIImage(named:"company")))
    }
    
}
