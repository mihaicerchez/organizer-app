//
//  LocationManager.swift
//  Organizer
//
//  Created by Mihai Cerchez on 01/10/2020.
//  Copyright © 2020 Mihai Cerchez. All rights reserved.
//
import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func didUpdateLocation(location:CLLocation)
}

final class LocationManager : NSObject, CLLocationManagerDelegate {
    
    static let sharedLocationManager = LocationManager()
    var userLocation: CLLocation!
    var isUpdatingLocation : Bool = false
    var delegate :LocationManagerDelegate?
    
    lazy var locationManager : CLLocationManager = {()->CLLocationManager in
        let lm = CLLocationManager()
        lm.delegate = self
        return lm
    }()
    
    private override init() {
        super.init()
    }
    
    func startUpdatingLocation(){
        if (isUpdatingLocation == false){
            isUpdatingLocation = true;
            if (locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))){
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation(){
        if (isUpdatingLocation){
            locationManager.stopUpdatingLocation()
            isUpdatingLocation = false;
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLoc = locations.last {
            delegate?.didUpdateLocation(location: userLoc)
        }
    }
    
}
