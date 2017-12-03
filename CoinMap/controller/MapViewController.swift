//
//  MapViewController.swift
//  CoinMap
//
//  Created by Lex Leontiev on 15/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    typealias JSONDictionary = [String: Any]
    
    var places: Array<Place> = Array()
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        performRequest()
    }
    
    func performRequest() {
        dataTask?.cancel()
        places.removeAll()
        if var urlComponents = URLComponents(string: "https://coinmap.org/api/v1/venues/") {
            urlComponents.query = "limit=10&lat1=55.712559&lat2=55.792559&lon1=37.577421&lon2=37.657421"
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.deliverResult(data: data)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    func deliverResult(data: Data) {
        parsePlaces(data: data)
    }
    
    func parsePlaces(data: Data) {
        var response: JSONDictionary?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            print("JSONSerialization error: \(parseError.localizedDescription)\n")
            return
        }
        
        guard let array = response!["venues"] as? [Any] else {
            print("Dictionary does not contain venues key\n")
            return
        }
        var index = 0
        for trackDictionary in array {
            if let trackDictionary = trackDictionary as? JSONDictionary {
                let id = trackDictionary["id"] as? Int
                let name = trackDictionary["name"] as? String
                let cat = trackDictionary["category"] as? String
                let lat = trackDictionary["lat"] as? Double
                let lon = trackDictionary["lon"] as? Double
                places.append(Place(id: id!, placeName: name!, categoryName: cat!, lat: lat!, lon: lon!))
                index += 1
            } else {
                print("Problem parsing venues\n")
            }
        }
        addPlacesToMap()
    }
    
    func addPlacesToMap() {
        var placeAnnotations = Array<MKPointAnnotation>()
        for place in places {
            let sourceLocation = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let sourceAnnotation = MKPointAnnotation()
            sourceAnnotation.title = place.placeName
            if let location = sourcePlacemark.location {
                sourceAnnotation.coordinate = location.coordinate
            }
            placeAnnotations.append(sourceAnnotation)
        }
        self.mapView.showAnnotations(placeAnnotations, animated: true )
        showCentredMap()
    }
    
    func showCentredMap() {
        let sourceLocation = CLLocationCoordinate2D(latitude: 55.752559, longitude: 37.617421)
        let viewRegion = MKCoordinateRegionMakeWithDistance(sourceLocation, 8000, 8000)
        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
    }
}

