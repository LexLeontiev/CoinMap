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
    let code: String
    let icon: UIImage!
    
    init(name: String, code: String, icon: UIImage!) {
        self.name = name;
        self.code = code;
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
        items.append(Category(name:"Cafe", code: "cafe", icon: UIImage(named:"cafe")))
        items.append(Category(name:"ATM", code: "atm", icon: UIImage(named:"atm")))
        items.append(Category(name:"Food", code: "food", icon: UIImage(named:"food")))
        items.append(Category(name:"Grocery", code: "grocery", icon: UIImage(named:"grocery")))
        items.append(Category(name:"Shopping", code: "shopping", icon: UIImage(named:"shop")))
        items.append(Category(name:"Nightlife", code: "nightlife", icon: UIImage(named:"bar")))
        items.append(Category(name:"Lodging", code: "lodging", icon: UIImage(named:"lodging")))
        items.append(Category(name:"Attraction", code: "attraction", icon: UIImage(named:"attraction")))
        items.append(Category(name:"Sport", code: "sports", icon: UIImage(named:"sport")))
        items.append(Category(name:"Transport", code: "transport", icon: UIImage(named:"transport")))
    }
    
}
