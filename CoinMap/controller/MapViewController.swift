//
//  MapViewController.swift
//  CoinMap
//
//  Created by Lex Leontiev on 15/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    typealias JSONDictionary = [String: Any]
    let locationManager = LocationManager()
    
    var places: Array<Place> = Array()
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.bindManager(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.unbindManager()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopListeningLocationChanges()
        print("update location")
        let location: CLLocationCoordinate2D = locationManager.getLastUpdatedLocation(locations)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1);
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        checkPlacesInThatRegion(region: region);
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    func checkPlacesInThatRegion(region: MKCoordinateRegion) {
        let span: MKCoordinateSpan = region.span
        let center: CLLocationCoordinate2D = region.center
        
        let minimumLatitude = center.latitude - span.latitudeDelta * 0.5
        let maximumLatitude = center.latitude + span.latitudeDelta * 0.5
        let minimumLongitude = center.longitude - span.longitudeDelta * 0.5
        let maximumLongitude = center.longitude + span.longitudeDelta * 0.5
        
        print("minimumLatitude = \(minimumLatitude)")
        print("maximumLatitude = \(maximumLatitude)")
        print("minimumLongitude = \(minimumLongitude)")
        print("maximumLongitude = \(maximumLongitude)")

        
        loadPlacesInRegion(minimumLatitude: minimumLatitude, maximumLatitude: maximumLatitude,
                           minimumLongitude: minimumLongitude, maximumLongitude: maximumLongitude)
    }
    
    func loadPlacesInRegion(minimumLatitude lat1: Double, maximumLatitude lat2: Double,
                            minimumLongitude lon1: Double, maximumLongitude lon2: Double) {
        dataTask?.cancel()
        places.removeAll()
        if var urlComponents = URLComponents(string: "https://coinmap.org/api/v1/venues/") {
            urlComponents.query = "limit=10&lat1=\(lat1)&lat2=\(lat2)&lon1=\(lon1)&lon2=\(lon2)"
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChange")
        checkPlacesInThatRegion(region: mapView.region)
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
    
    @IBAction func goToCurrentLocation(_ sender: Any) {
        locationManager.startListeningLocationChanges()
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
        self.mapView.addAnnotations(placeAnnotations)
    }

    func showCentredMap() {
        let sourceLocation = CLLocationCoordinate2D(latitude: 55.752559, longitude: 37.617421)
        let viewRegion = MKCoordinateRegionMakeWithDistance(sourceLocation, 8000, 8000)
        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
    }
}

