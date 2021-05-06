//
//  BusStopResource.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/14/21.
//

import Foundation

// A bus stop resource that conforms to APIResource that can be used to query the bus stops of a given operator and bus line
struct BusStopResource: APIResource {
    
    static let transitAgencyMaping: [String : String] = [
        "tri delta transit" : "3D",
        "ac transit" : "AC",
        "capital corridor joint powers authority" : "AM",
        "bay area rapid transit" : "BA",
        "county connection" : "CC",
        "altamont corridor express" : "CE",
        "commute.org shuttles" : "CM",
        "caltrain" : "CT",
        "dumbarton express consortium" : "DE",
        "emery go-round" : "EM",
        "fairfield and suisun transit" : "FS",
        "golden gate ferry" : "GF",
        "golden gate transit" : "GG",
        "marin transit" : "MA",
        "petaluma" : "PE",
        "regional gtfs" : "RG",
        "rio vista delta breeze" : "RV",
        "sonoma marin area rail transit" : "SA",
        "san francisco bay ferry" : "SB",
        "vta" : "SC",
        "san francisco municipal transportation agency" : "SF",
        "san francisco international airport" : "SI",
        "samtrans" : "SM",
        "sonoma county transit" : "SO",
        "santa rosa citybus" : "SR",
        "city of south san francisco" : "SS",
        "soltrans" : "ST",
        "tideline water taxi" : "TD",
        "union city transit" : "UC",
        "vacaville city coach" : "VC",
        "vine transit" : "VN",
        "westcat (western contra consta)" : "WC",
        "livermore amador valley transit authority" : "WH"
    ]
    
    private static let APIKey = "aa8b2487-376c-4179-88b5-039f82f4602d"
    
    // Model type is used to decode the raw binary data from web to the BusStopResponse object
    typealias ModelType = BusStopsResponse
    
    let methodPath = "/transit/stops"
    
    // We need to specify the operator Id (company of the bus) and the bus line for each bus stop query
    init(operatorID: String, lineID: String?) {
        queryItems["operator_id"] = operatorID
        if let lineID = lineID {
            queryItems["line_id"] = lineID
        }
    }
    
    var queryItems: Dictionary<String, String> = [
        "api_key" : BusStopResource.APIKey,
    ]
    
    var hostAddress: String = "https://api.511.org"
}
