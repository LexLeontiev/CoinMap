//
//  LocationManager.swift
//  CoinMap
//
//  Created by Lex Leontiev on 09/12/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerProtocol {

    func bindManager(_ delegate: CLLocationManagerDelegate?)
    func unbindManager()
    func startListeningLocationChanges();
    func stopListeningLocationChanges();
    func checkLocationPermission() -> Bool
    func getLastUpdatedLocation(_ locations: [CLLocation]) -> CLLocationCoordinate2D
}

class LocationManager: LocationManagerProtocol {
    
    let locationManager = CLLocationManager();
    
    init() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func bindManager(_ delegate: CLLocationManagerDelegate?) {
        locationManager.delegate = delegate
    }
    
    func unbindManager() {
        locationManager.delegate = nil
    }
    
    func startListeningLocationChanges() {
        if checkLocationPermission() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopListeningLocationChanges() {
        if checkLocationPermission() {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func checkLocationPermission() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func getLastUpdatedLocation(_ locations: [CLLocation]) -> CLLocationCoordinate2D {
        let lastUpdatedLocation: CLLocation = locations[0] as CLLocation
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lastUpdatedLocation.coordinate.latitude, lastUpdatedLocation.coordinate.longitude)
        return myLocation
    }
}

