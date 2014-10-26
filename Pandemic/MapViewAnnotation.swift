//
//  MapViewAnnotation.swift
//  pandemic-v2
//
//  Created by Akira Kyle on 9/27/14.
//  Copyright (c) 2014 Akira Kyle. All rights reserved.
//

import Foundation
import MapKit

class MapViewAnnotation: NSObject, MKAnnotation {
    
    var coordinate:CLLocationCoordinate2D
    
    override init() {
        coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    func getCoordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        coordinate.latitude = latitude
        coordinate.longitude = longitude
    }
    
}