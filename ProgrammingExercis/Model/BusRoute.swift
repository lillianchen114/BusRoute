//
//  BusRoute.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/13/21.
//

import Foundation

// This files describes the structs that are used to decode the bus route response from google and bus stop response from 511.org

struct BusRouteResponse: Decodable {
    let routes: [BusRoute]?
}

struct BusRoute {
    let path: [BusRoutePath]?
}

extension BusRoute: Decodable {
    enum CodingKeys: String, CodingKey {
        case path = "legs"
    }
}

struct BusRoutePath: Decodable {
    let steps: [BusRouteStep]?
}

struct BusRouteStep {
    let startLocation: Location
    let endLocation: Location
    let instruction: String
    let steps: [BusRouteStep]?
    let travelMode: String
    let transitInfo: TransitInfo?
}

extension BusRouteStep: Decodable {
    enum CodingKeys: String, CodingKey {
        case steps
        case instruction = "html_instructions"
        case startLocation = "start_location"
        case endLocation = "end_location"
        case travelMode = "travel_mode"
        case transitInfo = "transit_details"
    }
}

struct Location: Decodable {
    let lat: Double
    let lng: Double
}

struct TransitInfo: Decodable {
    let line: Line
    let departureStop: TransitStop
    let arrivalStop: TransitStop
    let numStops: Int
    
    enum CodingKeys: String, CodingKey {
        case line
        case departureStop = "departure_stop"
        case arrivalStop = "arrival_stop"
        case numStops = "num_stops"
    }
}

struct TransitStop: Decodable {
    let name: String
    let location: Location
}

struct Line: Decodable {
    let agencies : [Agency]
    let lineId: String?
    enum CodingKeys: String, CodingKey {
        case agencies
        case lineId = "short_name"
    }
}

struct Agency: Decodable {
    let name: String
}

// Bus stops model

struct BusStopsResponse: Decodable {
    let contents: BusStopsContent
    
    enum CodingKeys: String, CodingKey {
        case contents = "Contents"
    }
}

struct BusStopsContent: Decodable {
    let dataObjects: BusStopsData
}

struct BusStopsData: Decodable {
    let stopPoints: [BusStopPoint]
    
    enum CodingKeys: String, CodingKey {
        case stopPoints = "ScheduledStopPoint"
    }
}

struct BusStopPoint: Decodable {
    let name: String
    let location: BusStopLocation
    
    enum CodingKeys: String, CodingKey {
        case location = "Location"
        case name = "Name"
    }
}

struct BusStopLocation: Decodable {
    let longitude: String
    let latitude: String
    
    enum CodingKeys: String, CodingKey {
        case longitude = "Longitude"
        case latitude = "Latitude"
    }
}
