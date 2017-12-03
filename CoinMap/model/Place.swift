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
    let lat: Double
    let lon: Double
    
    // constructor for places with coodinats and without description
    init(id: Int, placeName: String, categoryName: String?, lat: Double, lon: Double) {
        self.id = id
        self.placeName = placeName
        self.categoryName = categoryName
        self.desc = ""
        self.lat = lat
        self.lon = lon
    }
    
    init(id: Int, placeName: String, categoryName: String?, desc: String?) {
        self.id = id
        self.placeName = placeName
        self.categoryName = categoryName
        self.desc = desc
        self.lat = 0.0
        self.lon = 0.0
    }
    
    init(corePlace: CorePlace) {
        self.id = Int(corePlace.placeId)
        self.placeName = corePlace.placeName ?? ""
        self.categoryName = corePlace.categoryName ?? ""
        self.desc = corePlace.desc ?? ""
        self.lat = 0.0
        self.lon = 0.0
    }
}
