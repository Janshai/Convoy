//
//  LocationServiceHandler.swift
//  Convoy
//
//  Created by Jack Adams on 03/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation
import CoreLocation
import MapboxCoreNavigation

class LocationServiceHandler: NSObject {
    public static let shared = LocationServiceHandler()
    
    var delegate: LocationServiceHandlerDelegate?
    
    private let coreLocationManager = CLLocationManager()
    private var mapBoxLocationManager: NavigationLocationManager?
    
    override init() {
        super.init()
        coreLocationManager.delegate = self
        coreLocationManager.startUpdatingLocation()
        requestServices()
    }
    
    var currentLocation: CLLocation? {
        if mapBoxLocationManager != nil {
            return mapBoxLocationManager!.location
        } else {
            return coreLocationManager.location
        }
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
    
    private func requestServices() {
        coreLocationManager.requestAlwaysAuthorization()
        
    }
    
    func setMapboxLocationManager(to manager: NavigationLocationManager) {
        self.mapBoxLocationManager = manager
    }
    
    func removeMapboxLocationManager() {
        self.mapBoxLocationManager = nil
    }
}

extension LocationServiceHandler: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.didUpdateLocation(location: locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let statuses: [CLAuthorizationStatus] = [.authorizedAlways, .authorizedWhenInUse]
        if statuses.contains(status) {
            manager.startUpdatingLocation()
        }
    }
}

protocol LocationServiceHandlerDelegate {
    func didUpdateLocation(location: CLLocation)
}
