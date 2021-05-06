//
//  PEBusRoute.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/11/21.
//

import Foundation
import CoreLocation
import MapKit

// A bus route object that stores information of the stating and ending location of the route
// It also stores the number of routes avaible between the start and end location
class PEBusRoute {
    private(set) var canQueryRoute: Box<Bool> = Box(false)
    
    private(set) var routes: [BusRouteModel] = []
    
    var startLocation: MKAnnotation? {
        didSet {
            updateQuerystate()
        }
    }
    var endLocation: MKAnnotation? {
        didSet {
            updateQuerystate()
        }
    }
    
    private func updateQuerystate() {
        canQueryRoute.value = (startLocation != nil) && (endLocation != nil)
    }
    
    func updateRoutes(routes: [BusRouteModel]) {
        self.routes = routes
    }
    
    // A method that is used after we fetched the bus stops for a given route
    func updateWithBusStops(busStops: [BusStopPoint], at index: Int) {
        routes[index].mergeWithBusStopPoint(busStopPoints: busStops)
    }
    
}
