//
//  JourneyViewController.swift
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

class JourneyViewController: UIViewController {
    
    var useMapBoxSimulation = true
    var overlayCount = 1
    var shouldBeginNavigation = false
    var convoy: ConvoyViewModel?
    
    var updateTimer: Timer?
    
    var options: NavigationRouteOptions?
    var route: Route?
    
    @IBOutlet weak var container: UIView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        LocationServiceHandler.shared.delegate = self
       
        if !LocationServiceHandler.shared.locationServicesEnabled() {
            //error
        }
        
        
        
    }
    
    func calculateDirections() {
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

        let navigationService = MapboxNavigationService(route: route, simulating: useMapBoxSimulation ? .always : .never)
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: route, options: navigationOptions)
        LocationServiceHandler.shared.setMapboxLocationManager(to: navigationService.locationManager)
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

    
    func setupJourney(for convoy: ConvoyViewModel) {
        self.convoy = convoy
        shouldBeginNavigation = true
    }
    
    func setupTurnByTurn() {
        if let location = LocationServiceHandler.shared.currentLocation?.coordinate, let convoy = self.convoy {
            let long = convoy.convoy.destination["long"]!
            let lat = convoy.convoy.destination["lat"]!
            let destination = CLLocationCoordinate2D(latitude: lat, longitude: long)
            options = NavigationRouteOptions(coordinates: [location, destination])
            calculateDirections()
        }
    }
    
    @objc func HandleMapViewUpdate() {
        if let location = LocationServiceHandler.shared.currentLocation {
            convoy?.updateCurrentLocation(to: location)
            if let coordinates = self.route?.coordinates {
                convoy?.updateRoute(to: coordinates.map({CLLocation(latitude: $0.latitude, longitude: $0.longitude)}))
            }
            convoy?.updateMembers() { c in
                if let members = c.members {
                    for m in members {
                        if m.userUID != c.userMember?.userUID, m.status == "In Progress" {
                            //add to the map
                        }
                    }
                }
                //update map view
            }
        }
            
    }
    
    func setupLocationSharing() {
        HandleMapViewUpdate()
        updateTimer = Timer(timeInterval: 5.0, target: self, selector: #selector(HandleMapViewUpdate), userInfo: nil, repeats: true)
        
        //look into life cycle when lock or close app and reopen
        
    }
    
    

}

extension JourneyViewController: LocationServiceHandlerDelegate {
    
    func didUpdateLocation(location: CLLocation) {
        if shouldBeginNavigation {
            shouldBeginNavigation = false
            setupTurnByTurn()
            setupLocationSharing()
        }
    }
    
    
}

