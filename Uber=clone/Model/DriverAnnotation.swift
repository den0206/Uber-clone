//
//  DriverAnnotation.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/09.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import MapKit

class DriverAnnotation : NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var uid : String
    
    init(_uid : String, _coodinate : CLLocationCoordinate2D) {
        self.uid = _uid
        self.coordinate = _coodinate
    }
    
    func updateAnnotationPosition(withCoodinate coodinate : CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coodinate
        }
    }
}
