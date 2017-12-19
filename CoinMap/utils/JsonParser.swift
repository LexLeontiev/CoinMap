//
//  JsonParser.swift
//  CoinMap
//
//  Created by Lex Leontiev on 19/12/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]

protocol JsonParserProtocol {
    static func parsePlace(_ data: Data) -> Place?
    static func parcePlaces(_ data: Data) -> Array<Place>
}

class JsonParser: JsonParserProtocol {
    
    static func parsePlace(_ data: Data) -> Place? {
        var result: Place?
        var response: JSONDictionary?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            print("JSONSerialization error: \(parseError.localizedDescription)\n")
            return result
        }
        
        guard let venueJson = response!["venue"] as? JSONDictionary else {
            print("Dictionary does not contain venues key\n")
            return result
        }
        let id = venueJson["id"] as? Int
        let name = venueJson["name"] as? String
        let cat = venueJson["category"] as? String
        let lat = venueJson["lat"] as? Double
        let lon = venueJson["lon"] as? Double
        result = Place(id: id!, placeName: name!, categoryName: cat!, lat: lat!, lon: lon!)
        return result
    }
    
    static func parcePlaces(_ data: Data) -> Array<Place> {
        var response: JSONDictionary?
        var result: Array<Place> = Array()
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            print("JSONSerialization error: \(parseError.localizedDescription)\n")
            return result
        }
        
        guard let array = response!["venues"] as? [Any] else {
            print("Dictionary does not contain venues key\n")
            return result
        }
        var index = 0
        for trackDictionary in array {
            if let trackDictionary = trackDictionary as? JSONDictionary {
                let id = trackDictionary["id"] as? Int
                let name = trackDictionary["name"] as? String
                let cat = trackDictionary["category"] as? String
                let lat = trackDictionary["lat"] as? Double
                let lon = trackDictionary["lon"] as? Double
                result.append(Place(id: id!, placeName: name!, categoryName: cat!, lat: lat!, lon: lon!))
                index += 1
            } else {
                print("Problem parsing venues\n")
            }
        }
        return result;
    }
}
