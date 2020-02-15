//
//  Trip.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/11.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import CoreLocation

struct Trip {
    
    var pickupCoodinates : CLLocationCoordinate2D!
    var destinationCoodenates : CLLocationCoordinate2D!
    
    let passangerUId : String!
    var driverUid : String?
    var state: TripState!
    
    init(_passangerUid : String, dictionary : [String : Any]) {
        
        passangerUId = _passangerUid
        
        if let pickupCoodinates = dictionary[kPICKUPCOODINATES] as? NSArray {
            guard let lat = pickupCoodinates[0] as? CLLocationDegrees else {return}
            guard let long = pickupCoodinates[1] as? CLLocationDegrees else {return}
            self.pickupCoodinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoodinates = dictionary[kDESTINATONCOODINATES] as? NSArray {
            guard let lat = destinationCoodinates[0] as? CLLocationDegrees else {return}
            guard let long = destinationCoodinates[1] as? CLLocationDegrees else {return}
            self.destinationCoodenates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUid = dictionary[kDRIVAERUID] as? String ?? ""
        
        if let state = dictionary[kSTATE] as? Int {
            self.state = TripState(rawValue: state)
        }
        
       
    }
    
    
}

enum TripState : Int {
    case requested
    case accepted
    case driverArrived
    case inProgress
    case completed
}
