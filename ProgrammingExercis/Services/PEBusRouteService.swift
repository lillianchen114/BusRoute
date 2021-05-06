//
//  PEBusRouteService.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/13/21.
//

import Foundation

// A bus route service class the is capable of retrieving bus routes between start and end location
// In addition, we can use it to query the bus stops along a given route
class PEBusRouteService {
    
    // Given the function types a new name for better syntax
    typealias postFetchCompletion = ([BusRouteModel]?, String?) -> Void
    typealias busStopPositions = ([BusStopPoint]?, String?) -> Void
    
    // A bus route request object that is used to fetch bus routes between two locations
    private var busRouteRequest: APIRequest<BusRouteResource>?
    
    // Array of bus stop requests that holds all the requests of querying bus stops for given bus routes
    private var busStopRequests: [APIRequest<BusStopResource>] = []
    
    // A method that asynchronously fetches all the bus routes between two locations
    func fetchBusRoutes(origin: String, destination: String , completion: @escaping postFetchCompletion) {
        let request = APIRequest(resource: BusRouteResource(originString: origin, destinationString: destination))
        busRouteRequest = request
        request.load { busRouteResponse, error in
            guard let busRouteResponse = busRouteResponse
            else {
                completion(nil, "Parsing Error")
                return
            }
            guard let routes = busRouteResponse.routes else {
                completion([], nil)
                return
            }
            // Convert the response to Bus routes model array that can be shown in the UI
            var possibleRoutes = [BusRouteModel]()
            for route in routes {
                if let paths = route.path {
                    for path in paths {
                        if let _ = path.steps {
                            possibleRoutes.append(BusRouteModel(with: path))
                        }
                    }
                }
            }
            completion(possibleRoutes, nil)
        }
    }
    
    // A method that fetches bus stops for all the routes described in the given bus route model
    func fetchBusStopsWithRoute(busRoute: BusRouteModel, completion: @escaping busStopPositions) {
        busStopRequests.removeAll()
        var transitInfos = [TransitInfo]()
        for step in busRoute.busRouteSteps {
            if step.travelMode == .bus {
                if let transitInfo = step.busInfo {
                    transitInfos.append(transitInfo)
                }
            }
        }
        // We only query for bus stops if there is at least one route
        if transitInfos.count > 0 {
            let busLines = buildBusLines(with: transitInfos)
            let busStops = Protected(resource: [BusStopPoint]())
            // Use dispatch group here because we want to wait until all bus stop fetch requests finish
            let group = DispatchGroup()
            for line in busLines {
                group.enter()
                let request = APIRequest(resource: BusStopResource(operatorID: line.agencyId, lineID: line.lineId))
                busStopRequests.append(request)
                request.load { [weak self] busStopResponse, error in
                    if let self = self {
                        if let busStopResponse =  busStopResponse {
                            busStops.mutate {
                                var mutableArray = $0
                                let rawStopPoints = busStopResponse.contents.dataObjects.stopPoints
                                mutableArray.append(contentsOf: self.aggregate(stops: rawStopPoints, departure: line.departureStop, arrival: line.arrivalStop, maxNumStops: line.maxNumStops))
                                return mutableArray
                            }
                        }
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                let busStopsData = busStops.read()
                completion(busStopsData, nil)
            }
        } else {
            completion(nil, nil)
        }
    }
    
    // Private method used to get all the buses needed for each route
    private func buildBusLines(with transitInfos: [TransitInfo]) -> [BusRouteMetadata] {
        var busLines = [BusRouteMetadata]()
        for transitInfo in transitInfos {
            for agent in transitInfo.line.agencies {
                let agencyName = agent.name.lowercased()
                if let agencyId = BusStopResource.transitAgencyMaping[agencyName] {
                    busLines.append(BusRouteMetadata(agencyId: agencyId, lineId: transitInfo.line.lineId, departureStop: transitInfo.departureStop.name, arrivalStop: transitInfo.arrivalStop.name, maxNumStops: transitInfo.numStops))
                }
            }
        }
        return busLines
    }
    
    // private method to find bus stops between departure stop and arrible stops
    private func aggregate(stops: [BusStopPoint], departure: String, arrival: String, maxNumStops: Int) -> [BusStopPoint] {
        var start: Int?
        var end: Int?
        for (index, stop) in stops.enumerated() {
            if stop.name == departure {
                start = index
            }
            if stop.name == arrival {
                end = index
            }
        }
        if let start = start, let end = end {
            if start < end {
                return Array(stops[start...end])
            } else {
                return Array(stops[end...start])
            }
        }
        if let start = start {
            if start + 1 > maxNumStops {
                return Array(stops[start..<stops.count])
            } else {
                return Array(stops[0...start])
            }
        }
        if let end = end {
            if end + 1 > maxNumStops {
                return Array(stops[end..<stops.count])
            } else {
                return Array(stops[0...end])
            }
        }
        return []
    }
}

struct BusRouteMetadata {
    let agencyId: String
    let lineId: String?
    let departureStop: String
    let arrivalStop: String
    let maxNumStops: Int
}
