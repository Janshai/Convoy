//
//  ViewController.swift
//  Convoy
//
//  Created by Jack Adams on 25/09/2019.
//  Copyright © 2019 Jack Adams. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    private let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if locationServicesEnabled() {
            mapView.showsUserLocation = true
            let annotation = MKPointAnnotation()
            annotation.coordinate = getLocationOf(friend: 1)
            annotation.title = "Steve"
            mapView.addAnnotation(annotation)
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            }
        }
        
    }
    
    func getLocationOf(friend id: Int) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 52.951790, longitude: -1.181260)
    }
    
    func locationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .denied:
                return false
            case .authorizedAlways:
                return true
            case .authorizedWhenInUse:
                return true
            case.notDetermined:
                requestServices()
                return false
            case .restricted:
                return false
            default:
                return false
            }
        } else {
            // TODO: Alert device wide services disabled
            return false
        }
    }
    
    func requestServices() {
        locationManager.requestAlwaysAuthorization()
        
    }

}

extension ViewController: MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    
}

