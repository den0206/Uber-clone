//
//  LocationHandler.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/09.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import CoreLocation

class LocationHandler : NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    var locationManager : CLLocationManager!
    var location : CLLocation?
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
