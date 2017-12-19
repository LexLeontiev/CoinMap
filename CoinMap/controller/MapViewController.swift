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
    
    fileprivate let locationManager = LocationManager()
    
    fileprivate var minimumLatitude: Double = 0.0;
    fileprivate var maximumLatitude: Double = 0.0;
    fileprivate var minimumLongitude: Double = 0.0;
    fileprivate var maximumLongitude: Double = 0.0;
    
    fileprivate let placesLimit = 100;

    fileprivate var selectedPlaceId: Int?
    fileprivate var placeSet = Set<Place>()
    fileprivate let defaultSession = URLSession(configuration: .default)
    fileprivate var dataTask: URLSessionDataTask?
    
    @IBOutlet weak var mapView: MKMapView!
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")

        locationManager.bindManager(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")

        locationManager.unbindManager()
    }
    
    //Location callbacks
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopListeningLocationChanges()
        let location: CLLocationCoordinate2D = locationManager.getLastUpdatedLocation(locations)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1);
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        checkPlacesInThatRegion(region: region);
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    //MapView callbacks
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        checkPlacesInThatRegion(region: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        guard let annotation = view.annotation as? PlacePointAnnotation else {
            print("The annotation is not an instance of PlacePointAnnotation.")
            return
        }
        self.selectedPlaceId = annotation.placeId
        showDetailPlacePopup()
    }
    
    //Segue callbacks
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailPlacePopupSegue" {
            guard let vc = segue.destination as? PlaceViewController else {
                print("The destination view controller is not an instance of PlaceViewController.")
                return
            }
            vc.placeId = self.selectedPlaceId
        }
    }
    
    //Actions
    @IBAction func goToCurrentLocation(_ sender: Any) {
        locationManager.startListeningLocationChanges()
    }
    
    //Methods
    fileprivate func checkPlacesInThatRegion(region: MKCoordinateRegion) {
        let span: MKCoordinateSpan = region.span
        let center: CLLocationCoordinate2D = region.center
        
        let minimumLatitude = center.latitude - span.latitudeDelta * 0.5
        let maximumLatitude = center.latitude + span.latitudeDelta * 0.5
        let minimumLongitude = center.longitude - span.longitudeDelta * 0.5
        let maximumLongitude = center.longitude + span.longitudeDelta * 0.5
        
        guard minimumLatitude < self.minimumLatitude
            || maximumLatitude > self.maximumLatitude
            || minimumLongitude < self.minimumLongitude
            || maximumLongitude > self.maximumLongitude else {
                return
        }
        
        loadPlacesInRegion(minimumLatitude: minimumLatitude, maximumLatitude: maximumLatitude,
                           minimumLongitude: minimumLongitude, maximumLongitude: maximumLongitude)
    }
    
    fileprivate func loadPlacesInRegion(minimumLatitude lat1: Double, maximumLatitude lat2: Double,
                            minimumLongitude lon1: Double, maximumLongitude lon2: Double) {
        print("loadPlacesInRegion")
        dataTask?.cancel()
        if var urlComponents = URLComponents(string: "https://coinmap.org/api/v1/venues/") {
            urlComponents.query = "limit=\(self.placesLimit)&lat1=\(lat1)&lat2=\(lat2)&lon1=\(lon1)&lon2=\(lon2)"
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.minimumLatitude = lat1
                        self.maximumLatitude = lat2
                        self.minimumLongitude = lon1
                        self.maximumLongitude = lon2
                        self.deliverPlacesResult(data: data)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    fileprivate func deliverPlacesResult(data: Data) {
        let places = JsonParser.parcePlaces(data)
        var update = Array<Place>()
        for place in places {
            if !placeSet.contains(place) {
                placeSet.insert(place)
                update.append(place)
            }
        }
        addPlacesToMap(update)
    }
    
    fileprivate func showDetailPlacePopup() {
        self.performSegue(withIdentifier: "detailPlacePopupSegue", sender: self)
    }
    
    fileprivate func addPlacesToMap(_ places: Array<Place>) {
        var placeAnnotations = Array<MKPointAnnotation>()
        for place in places {
            let sourceLocation = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let sourceAnnotation = PlacePointAnnotation()
            sourceAnnotation.title = place.placeName
            sourceAnnotation.placeId = place.id
            if let location = sourcePlacemark.location {
                sourceAnnotation.coordinate = location.coordinate
            }
            placeAnnotations.append(sourceAnnotation)
        }
        self.mapView.addAnnotations(placeAnnotations)
    }
}
