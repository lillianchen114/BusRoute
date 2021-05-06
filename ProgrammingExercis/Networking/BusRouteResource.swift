//
//  BusRouteResource.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/13/21.
//

import Foundation

// A bus route resource that conforms to API resource protocol. It defines how we can query for a bus route between to lowcaions
struct BusRouteResource: APIResource {
    
    private static let APIKey = "AIzaSyDbGJkMBWVEstOsTHHF3HMeUYDmoChtrr0"
    
    // The model type is used to decode the raw binary data from internet
    typealias ModelType = BusRouteResponse
    
    let methodPath = "/maps/api/directions/json"
    
    // We need to know the starting end ending location for a given bus route
    init(originString: String, destinationString: String) {
        queryItems["origin"] = "\(originString)"
        queryItems["destination"] = "\(destinationString)"
    }
    
    var queryItems: Dictionary<String, String> = [
        "key" : BusRouteResource.APIKey,
        "mode" : "transit",
        "transit_mode" : "bus"
    ]
    
    var hostAddress: String = "https://maps.googleapis.com"
}
