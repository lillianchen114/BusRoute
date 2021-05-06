//
//  PESearchResult.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/11/21.
//

import Foundation
import CoreLocation

// This is used to describe the point of interest search result
// It contains a name and a location that describes the latitude and longitude
struct SearchResult {
    let location: CLLocation
    let name: String
}
