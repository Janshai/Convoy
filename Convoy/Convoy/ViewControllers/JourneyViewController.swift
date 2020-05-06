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
    
    var routeLines = [String : MKPolyline]()
    var locations = [MKPointAnnotation]()
    
    var updateTimer: Timer?
    
    var options: NavigationRouteOptions?
    var route: Route?
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var routeMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        routeMapView.isHidden = true
        routeMapView.delegate = self
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
            var newRouteLines = [String : MKPolyline]()
            var newLocations = [MKPointAnnotation]()
            var allCoordinates: [CLLocationCoordinate2D] = []
            
            convoy?.updateCurrentLocation(to: location)
            
            let userLoc = MKPointAnnotation()
            userLoc.title = "You"
            userLoc.coordinate = location.coordinate
            newLocations.append(userLoc)
            if let coordinates = self.route?.coordinates {
                allCoordinates += coordinates
                convoy?.updateRoute(to: coordinates.map({CLLocation(latitude: $0.latitude, longitude: $0.longitude)}))
                let userPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                userPolyline.title = "Your Route"
                newRouteLines[UserViewModel.currentUser] = userPolyline
            }
            
            
            
            convoy?.updateMembers() { [weak self] c in
                for m in c.members {
                    if m.member.userUID != UserViewModel.currentUser, m.status == "In Progress" {
                        if let coordinates = m.route?.map({$0.coordinate}) {
                            allCoordinates += coordinates
                            let line = MKPolyline(coordinates: coordinates, count: coordinates.count)
                            newRouteLines[m.member.userUID] = line
                        }
                        
                        if let location = m.currentLocation {
                            let point = MKPointAnnotation()
                            point.coordinate = location.coordinate
                            point.subtitle = m.name
                            newLocations.append(point)
                        }
                        
                    }
                }
                
                
                
                //update map view
                if let strongSelf = self {
                    let overlays: [MKPolyline] = Array(strongSelf.routeLines.values)
                    strongSelf.routeMapView.removeOverlays(overlays)
                    let newOverlays: [MKPolyline] = Array(newRouteLines.values)
                    strongSelf.routeMapView.addOverlays(newOverlays)
                    strongSelf.routeMapView.removeAnnotations(strongSelf.locations)
                    strongSelf.routeMapView.addAnnotations(newLocations)
                    if Array(newRouteLines.keys) != Array(strongSelf.routeLines.keys) {
                        
                        let points = allCoordinates.map { MKMapPoint($0) }
                        let rects = points.map { MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0)) }
                        let fittingRect = rects.reduce(MKMapRect.null)  { $0.union($1) }
                        
                        strongSelf.routeMapView.setVisibleMapRect(fittingRect, edgePadding: UIEdgeInsets(floatLiteral: 10.0), animated: true)
                    }
                    strongSelf.routeLines = newRouteLines
                    strongSelf.locations = newLocations
                }
                
                
                
            }
        }
            
    }
    
    func setupLocationSharing() {
        routeMapView.alpha = 0
        routeMapView.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.routeMapView.alpha = 1
        }
        HandleMapViewUpdate()
        updateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(HandleMapViewUpdate), userInfo: nil, repeats: true)
        
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

extension JourneyViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 4.0
        renderer.strokeColor = overlay.title == "Your Route" ? .blue : .green
        return renderer
    }
    
    
}
