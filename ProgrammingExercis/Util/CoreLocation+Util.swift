//
//  CoreLocation+Util.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/10/21.
//

import Foundation
import CoreLocation

extension CLLocation {
    static let defaultLocation = CLLocation(latitude: 37.3677, longitude: -122.0329)
}

extension CLLocationCoordinate2D {
    
    // A convenient computed variable that converts the location's coordinate from double to string
    var coordinateString: String {
        return "\(self.latitude),\(self.longitude)"
    }
}
