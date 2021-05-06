//
//  BusRouteModel.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/13/21.
//

import Foundation
import CoreLocation

//This struct defines bus route model that includes start and end location as well as all the routes information
struct BusRouteModel {
    let busRouteSteps: [BusRoutePoint]
    private(set) var polylinePoints = [PolylinePoint]()
    
    init(with busRoutePath: BusRoutePath) {
        guard let path = busRoutePath.steps else {
            busRouteSteps = []
            return
        }
        if path.count == 0 {
            busRouteSteps = []
            return
        }
        var points = [BusRoutePoint]()
        BusRouteModel.getAllBusRoutePointFromPath(steps: path, busRoutePoint: &points)
        busRouteSteps = points
    }
    
    //This is a static method that converts a single instruction of take bus from point A to point B into different bus stops
    private static func getAllBusRoutePointFromPath(steps: [BusRouteStep], busRoutePoint: inout [BusRoutePoint]) {
        for step in steps {
            var routePoint = BusRoutePoint(startLocation: CLLocationCoordinate2D(latitude: step.startLocation.lat, longitude: step.startLocation.lng),
                                           endLocation: CLLocationCoordinate2D(latitude: step.endLocation.lat, longitude: step.endLocation.lng) ,
                                           instruction: step.instruction.removedHTMLTags,
                                           travelMode: (step.travelMode == "WALKING") ? .walking : .bus)
            routePoint.busInfo = step.transitInfo
            busRoutePoint.append(routePoint)
            if let subSteps = step.steps, subSteps.count > 0 {
                BusRouteModel.getAllBusRoutePointFromPath(steps: subSteps, busRoutePoint: &busRoutePoint)
            }
        }
    }
    
    // Converts all the locations along this route path to location coordinate that can be displayed on the map view
    func pathLocations() -> [CLLocationCoordinate2D] {
        return polylinePoints.map { $0.location }
    }
    
    // A convenient method for converting the instruction of a route object to a string that can be displayed on screen
    func pathInstructions() -> String {
        var instructions = ""
        for i in 0..<busRouteSteps.count {
            if i == busRouteSteps.count - 1 {
                instructions += "Step \(i + 1): \(busRouteSteps[i].instruction)"
            } else {
                instructions += "Step \(i + 1): \(busRouteSteps[i].instruction)\n"
            }
        }
        return instructions
    }
    
    // This method replaces the aggregate bus taking instruction to detailed bus stops
    mutating func mergeWithBusStopPoint(busStopPoints: [BusStopPoint]) {
        polylinePoints.removeAll()
        for step in busRouteSteps {
            if step.travelMode != .bus {
                polylinePoints.append(PolylinePoint(location: step.startLocation, name: "", type: .walking))
            }
        }
        for stop in busStopPoints {
            polylinePoints.append(PolylinePoint(location: CLLocationCoordinate2D(latitude: Double(stop.location.latitude)!, longitude: Double(stop.location.longitude)!), name: stop.name, type: .bus))
        }
    }
}

// Some helper enum and struct definition

enum TravelType {
    case walking
    case bus
}

struct PolylinePoint {
    let location: CLLocationCoordinate2D
    let name: String
    let type: TravelType
}

struct BusRoutePoint {
    let startLocation: CLLocationCoordinate2D
    let endLocation: CLLocationCoordinate2D
    let instruction: String
    let travelMode: TravelType
    var busInfo: TransitInfo?
}
