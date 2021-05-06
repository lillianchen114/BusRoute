//
//  MKMapView+Util.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/10/21.
//

import Foundation
import MapKit

// Defines some helper method that we can use for the mapview
extension MKMapView {
    
    //Centers the map view to a given location and region radius
    func centerToLocation(location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
    // Add annotation to the map view at given location with title and subtitle (can be nil)
    static func annotationWith(location: CLLocation, title: String, subtitle: String?) -> MKAnnotation {
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        pin.title = title
        pin.subtitle = subtitle
        return pin
    }
    
    // Same method as above, the only difference is that it takes a raw location cocrdinate instead of a full location object
    static func annotationWith(coordinate: CLLocationCoordinate2D, title: String, subtitle: String?) -> MKAnnotation {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = title
        pin.subtitle = subtitle
        return pin
    }
    
    // This is a convenient method that centers the map view to the default location in case user does not grant location access
    func centerToDefaultLocation() {
        centerToLocation(location: CLLocation.defaultLocation)
    }
    
    // A convenient method that draws the polyline for a given bus route
    func drawPolylineWithRoute(busRoute: BusRouteModel) {
        let overlays = self.overlays
        self.removeOverlays(overlays)
        let locations = busRoute.pathLocations()
        let polyline = MKPolyline(coordinates: locations, count: locations.count)
        self.addOverlay(polyline)
    }
    
    // A computed variable that returns the current map view region
    var currentRegion: MKCoordinateRegion {
        return MKCoordinateRegion(center: self.centerCoordinate, latitudinalMeters: 500000, longitudinalMeters: 500000)
    }
}
