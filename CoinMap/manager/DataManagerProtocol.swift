//
//  DataManagerProtocol.swift
//  CoinMap
//
//  Created by Lex Leontiev on 25/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import Foundation

protocol DataManagerProtocol {
    
    func savePlace(place: Place)
    func removePlace(id: Int)
    func getPlace(id: Int) -> Place?
    func checkPlace(id: Int) -> Bool
}
