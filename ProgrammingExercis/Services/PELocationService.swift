//
//  PELocationService.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/10/21.
//

import Foundation
import CoreLocation
import MapKit

// Location service class used to retrieve user's current location and fetch Points of interest (POI) with given keywords
class PELocationService: NSObject, CLLocationManagerDelegate {
    
    // Location manager used for getting user's location
    private var locationManager: CLLocationManager = CLLocationManager()
    
    // A boolean indicate whether user have granted location access or not
    private(set) var isLocationAccessGranted: Box<Bool> = Box(false)
    
    // A variable the holds the current location of the user
    private(set) var currentLocation: Box<CLLocation?> = Box(nil)
    
    // A variable that holds the current POI search
    // we need it because we can cancel it if a new search request came before the current search finishes
    private var currentSearch: MKLocalSearch?
    
    // Setup location manager in init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        isLocationAccessGranted.value = (locationManager.authorizationStatus == .authorizedWhenInUse)
        if !isLocationAccessGranted.value && locationManager.authorizationStatus == .denied {
            currentLocation.value = CLLocation.defaultLocation
        }
    }
    
    // A method that asynchronously fetches the detail of user's current location
    typealias locationLookupCompletion = (String) -> Void
    func lookupCurrentLocation(completion: @escaping locationLookupCompletion) {
        guard let location = currentLocation.value else { return }
        let geocoder = CLGeocoder()
        // Use weak here to avoid retain cycle
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let _ = self {
                if let placemarks = placemarks, placemarks.count > 0 {
                    let placemark = placemarks[0]
                    completion(placemark.name ?? "Unknown Location")
                } else {
                    completion("lat: \(location.coordinate.latitude), long: \(location.coordinate.longitude)")
                }
            } else {
                completion("Unknown Location")
            }
        }
    }
    
    // A method that asynchronously fetches the points of interest in a given region and with given keywords
    typealias poisearchCompletion = ([SearchResult]) -> Void
    func searchPlaceWithKeyWords(keywords: String, region: MKCoordinateRegion, completion: @escaping poisearchCompletion) {
        if let search = currentSearch {
            search.cancel()
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keywords
        request.region = region
        currentSearch = MKLocalSearch(request: request)
        currentSearch!.start { response, _ in
            DispatchQueue.main.async {
                if let response = response {
                    var result = [SearchResult]()
                    for item in response.mapItems {
                        if let location = item.placemark.location {
                            result.append(SearchResult(location: location, name: item.name ?? "Unknown"))
                        }
                    }
                    completion(result)
                } else {
                    completion([])
                }
            }
        }
    }
    
    // A method that starts the updating of user's current location
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
//    MARK: - CLLocationManagerDelegate
    
    // location manager's authentication state change callback
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            isLocationAccessGranted.value = true
        }
    }
    
    // This method get called when location manager receives updates of user's current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation.value = locations[0]
        manager.stopUpdatingLocation()
    }
    
    // This method get called when location manager fails to retrieve user's current location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.locationServicesEnabled() {
            isLocationAccessGranted.value = true
        }
    }
}
