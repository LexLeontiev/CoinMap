//
//  Place.swift
//  CoinMap
//
//  Created by Lex Leontiev on 03/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit

class Place {
    
    let id: Int
    let placeName: String
    let categoryName: String?
    let desc: String?
    
    init(id: Int, placeName: String, categoryName: String?, desc: String?) {
        self.id = id
        self.placeName = placeName
        self.categoryName = categoryName
        self.desc = desc
    }
    
    init(corePlace: CorePlace) {
        self.id = Int(corePlace.placeId)
        self.placeName = corePlace.placeName ?? ""
        self.categoryName = corePlace.categoryName ?? ""
        self.desc = corePlace.desc ?? ""
    }
}
