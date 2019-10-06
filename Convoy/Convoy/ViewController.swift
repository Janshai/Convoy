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
    
    var overlayCount = 1
    
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
            
            if let location = locationManager.location?.coordinate {
                let lidl = CLLocationCoordinate2D(latitude: 52.959670, longitude: -1.183520)
                let userRequest = getDirectionsRequest(from: location, to: lidl)
                let friendRequest = getDirectionsRequest(from: getLocationOf(friend: 1), to: lidl)
                let userDirections = MKDirections(request: userRequest)
                let friendDirections = MKDirections(request: friendRequest)
                
                let group = DispatchGroup()
                group.enter()
                group.enter()
                var routes = [MKRoute]()
                userDirections.calculate() { (response, error) in
                    routes += response!.routes
                    group.leave()
                }
                friendDirections.calculate() { (response, error) in
                    routes += response!.routes
                    
                    group.leave()
                }
                
                group.notify(queue: DispatchQueue.main) { [unowned self] in
                    for route in routes {
                        print(route.debugDescription)
                        let line = route.polyline
                        self.mapView.addOverlay(line)
                        
                    }
                    
                    self.mapView.setVisibleMapRect(routes[0].polyline.boundingMapRect, animated: true)
                }
                
                let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            }
        }
        
    }
    
    func getLocationOf(friend id: Int) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 52.954640, longitude: -1.193140)
    }
    
    func getDirectionsRequest(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> MKDirections.Request {
        let startPlacemark = MKPlacemark(coordinate: start)
        let endPlacemark = MKPlacemark(coordinate: end)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPlacemark)
        request.destination = MKMapItem(placemark: endPlacemark)
        request.transportType = .walking
        
        return request
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)-> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay)
        switch overlayCount {
        case 1:
            renderer.strokeColor = UIColor.blue
        default:
            renderer.strokeColor = UIColor.green
        }
        
        renderer.lineWidth = 5.0
        overlayCount += 1
        return renderer
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    
}

