//
//  Place.swift
//  CoinMap
//
//  Created by Lex Leontiev on 03/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit

class Place: Hashable {

    var hashValue: Int {
        return id.hashValue
    }
    
    let id: Int
    let placeName: String
    let categoryName: String?
    let lat: Double
    let lon: Double
    
    var desc: String?
    var address: String?
    var country: String?
    var website: String?
    
    var isFavorite: Bool = false
    
    init(id: Int) {
        self.id = id
        self.placeName = ""
        self.categoryName = ""
        self.lat = 0.0
        self.lon = 0.0
    }
    
    // constructor for places with coodinats and without description
    init(id: Int, placeName: String, categoryName: String?, lat: Double, lon: Double) {
        self.id = id
        self.placeName = placeName
        self.categoryName = categoryName
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
        self.lat = corePlace.lat
        self.lon = corePlace.lon
        self.country = corePlace.country ?? ""
        self.website = corePlace.website ?? ""
        self.address = corePlace.address ?? ""
    }
    
    static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
}
