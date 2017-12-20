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
    
    var placeManager: DataManagerProtocol!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    fileprivate var minimumLatitude: Double = 0.0;
    fileprivate var maximumLatitude: Double = 0.0;
    fileprivate var minimumLongitude: Double = 0.0;
    fileprivate var maximumLongitude: Double = 0.0;
    
    fileprivate let placesLimit = 100;

    fileprivate var selectedPlaceId: Int?
    fileprivate var placeSet = Set<Place>()
    fileprivate let defaultSession = URLSession(configuration: .default)
    fileprivate var dataTask: URLSessionDataTask?
    
    fileprivate var catFilter: String = ""
    
    @IBOutlet weak var mapView: MKMapView!
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load core data place manager
        self.placeManager = CoreDataManager(context: context)
        
        //register notification observer
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppDelegate.mySpecialNotificationKey), object: nil, queue: nil, using: catchNotification)
        
        mapView.delegate = self
    }
    
    func catchNotification(notification:Notification) -> Void {
        if let notifPlaceId = notification.userInfo!["placeId"] as? Int64 {
            let placeId = Int(notifPlaceId)
            let lat = notification.userInfo!["lat"] as? Double
            let lon = notification.userInfo!["lon"] as? Double
            
            // add place on map if needed
            let place = Place(id: placeId);
            if !placeSet.contains(place) {
                print("place not exist")
                let fullPlace = placeManager?.getPlace(id: placeId)
                placeSet.insert(fullPlace!)
                var update = Array<Place>()
                update.append(fullPlace!)
                addPlacesToMap(update)
            }
            
            // scroll map to place
            let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05);
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            mapView.setRegion(region, animated: true)
        }
        if let cat = notification.userInfo!["cat"] {
            //select category
            catFilter = (cat as? String)!
            updateMapWithCategory(catFilter)
            checkPlacesInThatRegion(region: mapView.region)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        locationManager.bindManager(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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
    
    @IBAction func clearFilter(_ sender: Any) {
        catFilter = ""
        updateMapWithCategory(catFilter)
        checkPlacesInThatRegion(region: mapView.region)
    }
    
    //Methods
    fileprivate func checkPlacesInThatRegion(region: MKCoordinateRegion) {
        let span: MKCoordinateSpan = region.span
        let center: CLLocationCoordinate2D = region.center
        
        let minimumLatitude = center.latitude - span.latitudeDelta * 0.5
        let maximumLatitude = center.latitude + span.latitudeDelta * 0.5
        let minimumLongitude = center.longitude - span.longitudeDelta * 0.5
        let maximumLongitude = center.longitude + span.longitudeDelta * 0.5
        
//        updateMapWithCategory(catFilter)
        
//        guard minimumLatitude < self.minimumLatitude
//            || maximumLatitude > self.maximumLatitude
//            || minimumLongitude < self.minimumLongitude
//            || maximumLongitude > self.maximumLongitude else {
//                return
//        }
        
        loadPlacesInRegion(minimumLatitude: minimumLatitude, maximumLatitude: maximumLatitude,
                           minimumLongitude: minimumLongitude, maximumLongitude: maximumLongitude)
    }
    
    fileprivate func loadPlacesInRegion(minimumLatitude lat1: Double, maximumLatitude lat2: Double,
                            minimumLongitude lon1: Double, maximumLongitude lon2: Double) {
        print("loadPlacesInRegion")
        dataTask?.cancel()
        if var urlComponents = URLComponents(string: "https://coinmap.org/api/v1/venues/") {
            var query = "limit=\(self.placesLimit)&lat1=\(lat1)&lat2=\(lat2)&lon1=\(lon1)&lon2=\(lon2)"
            print("catFilter = \(catFilter)")
            if (catFilter != "") {
                query += "&category=\(catFilter)"
            }
            urlComponents.query = query;
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
    
    fileprivate func updateMapWithCategory(_ category: String) {
        let annotations = self.mapView.annotations
        var annotationsForRemove = Array<MKPointAnnotation>()
        for annotation in annotations {
//            if category == "" {
//                mapView.view(for: annotation)?.isHidden = false
//            }
//            if let placePointAnnotation = annotation as? PlacePointAnnotation {
//                if placePointAnnotation.placeCategory != category {
//                     mapView.view(for: annotation)?.isHidden = true
//                } else {
//                     mapView.view(for: annotation)?.isHidden = false
//                }
//            }
            if let placePointAnnotation = annotation as? PlacePointAnnotation {
                if placePointAnnotation.placeCategory != category {
                    annotationsForRemove.append(placePointAnnotation)
                    placeSet.remove(Place(id: placePointAnnotation.placeId))
                }
            }
        }
        mapView.removeAnnotations(annotationsForRemove)
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
            sourceAnnotation.placeCategory = place.categoryName
            if let location = sourcePlacemark.location {
                sourceAnnotation.coordinate = location.coordinate
            }
            placeAnnotations.append(sourceAnnotation)
        }
        self.mapView.addAnnotations(placeAnnotations)
    }
}
