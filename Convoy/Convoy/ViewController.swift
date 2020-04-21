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
import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation

class ViewController: UIViewController {
    
    var overlayCount = 1
    
    private let locationManager = CLLocationManager()
    var options: NavigationRouteOptions?
    var route: Route?
    
    @IBOutlet weak var container: UIView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        locationManager.delegate = self
        if locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
            if let location = locationManager.location?.coordinate {
                let lidl = CLLocationCoordinate2D(latitude: 52.959670, longitude: -1.183520)
                options = NavigationRouteOptions(coordinates: [location, lidl])
                calculateDirections()
            }
        }
        
    }
    
    func getLocationOf(friend id: Int) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 52.954640, longitude: -1.193140)
    }
    
    func calculateDirections() {
        print("Hi")
        if let ops = options {
            Directions.shared.calculate(ops) { (waypoints, routes, error) in
                guard let route = routes?.first, error == nil else {
                   print(error!.localizedDescription)
                   return
                }
                self.route = route
                self.startEmbeddedNavigation()
            }
        }

    }

    func startEmbeddedNavigation() {
        guard let route = self.route else { return }

        let navigationService = MapboxNavigationService(route: route, simulating:.always)
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: route, options: navigationOptions)

        addChild(navigationViewController)
        container.addSubview(navigationViewController.view)
        navigationViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationViewController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            navigationViewController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            navigationViewController.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            navigationViewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        ])
        self.didMove(toParent: self)


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

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        return
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

