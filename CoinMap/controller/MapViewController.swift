//
//  MapViewController.swift
//  CoinMap
//
//  Created by Lex Leontiev on 15/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let sourceLocation = CLLocationCoordinate2D(latitude: 55.752559, longitude: 37.617421)
        let viewRegion = MKCoordinateRegionMakeWithDistance(sourceLocation, 8000, 8000)
        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Moscow"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        self.mapView.showAnnotations([sourceAnnotation], animated: true )
        self.mapView.setRegion(adjustedRegion, animated: true)
    }
}

