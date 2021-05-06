//
//  PEMainViewController.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/10/21.
//

import UIKit
import MapKit

// The main view controller that user will see through out the app
// Allows user to search for starting location and destination. Then query the bus route.
// It will also display the polyline of the route and the bus stop annotations on that route.
class PEMainViewController: UIViewController {
    
    // UI elements will be used in the view controller
    
    // A map that will be used to display polylines and annotations
    private var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    // A customized search view that have two search bars to allow user to search POI(point of interests) on the map
    // User can select the search result as starting position and the destination of the route
    private var topSearchView: PETopSearchView = {
        let searchView = PETopSearchView(frame: .zero)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        return searchView
    }()
    
    // A customized button that can display a loading indicator when pressed
    // It will only be shown when there is a starting location and a destination
    // When user taps on it, we will query the route between starting location and destination using google direction API
    private var busRouteQueryButton: PELoadingButton = {
        let button = PELoadingButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = PELoadingButton.loadingButtonSize / 2.0
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.shadowRadius = 3.0
        button.layer.shadowOpacity = 0.6
        button.isHidden = true
        button.alpha = 0
        return button
    }()
    
    // Services
    
    // Location service object to retrieve user location and query points of interest based on keyword from user
    private var locationService: PELocationService
    
    // Bus route service for querying bus route between two locations
    private var busRouteService: PEBusRouteService
    
    // A child view controller use to display the search result from user input in the top search view
    private let searchResultController = PESearchTableViewController()
    
    // Height of the top search view, equal to 30% of the screen height
    private let searchResultViewHeight = UIScreen.main.bounds.height * 0.3
    
    // A bus route model object use to store the start, end location and routes
    private let busRoute: PEBusRoute = PEBusRoute()
    
    // Array of annotations of the bus stops for the current route, initially is empty
    private var busAnnotations = [MKAnnotation]()
    
//    MARK: - Constants
    
    // Reuse identifier of the pin on mapview
    static private let pinReuseId: String = "PinId"
    
    // Custom initializer that takes a locationService and a busRouteService
    init(locationService: PELocationService, busRouteService: PEBusRouteService) {
        self.locationService = locationService
        self.busRouteService = busRouteService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // After our main view is loaded, we will do initial setup of our subviews and child view controllers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup child view controller: search result view controller
        searchResultController.view.translatesAutoresizingMaskIntoConstraints = false
        searchResultController.view.isHidden = true
        searchResultController.view.alpha = 0
        
        // Make mainViewController be the delegate of the child views/viewcontrollers
        searchResultController.delegate = self
        topSearchView.searchDelegate = self
        mapView.delegate = self
        
        // Add target action for the bus route query button that reacts to users tap
        busRouteQueryButton.addTarget(self, action: #selector(didTapBusRouteQueryButton), for: .touchUpInside)
        
        //Add subviews to main view
        view.addSubview(mapView)
        view.addSubview(topSearchView)
        view.addSubview(busRouteQueryButton)
        view.addSubview(searchResultController.view)
        addChild(searchResultController)
        setupConstraints()
        
        // Binds property on service to main view controller. It will get notified when currenctLocation and isLocationAccessGranted changes
        locationService.currentLocation.bind(listener: didUpdateLocation(location:))
        locationService.isLocationAccessGranted.bind { [weak self] granted in
            if let self = self {
                if granted {
                    self.locationService.startUpdating()
                }
            }
        }
        
        // Bind the canQueryRoute from busRoute model, this is used to determine whether we show the bus routing button or not
        busRoute.canQueryRoute.bind(listener: didUpdateCanQueryRouteState(canShowRoute:))
    }
    
    // This is called after location service have updated current user's location
    // We will center the map to user's current location, and use this location as user's starting position, add a pin to the map
    private func didUpdateLocation(location: CLLocation?) {
        guard let location = location else { return }
        mapView.centerToLocation(location: location)
        locationService.lookupCurrentLocation { [weak self] name in
            if let self = self {
                self.topSearchView.updateLocationName(name: name, selection: .from)
                self.busRoute.startLocation = MKMapView.annotationWith(location: location, title: name, subtitle: nil)
                self.mapView.addAnnotation(self.busRoute.startLocation!)
            }
        }
    }
    
    // The logic of hide and show bus route query button. Only when we have both start and end location we will show the button
    private func didUpdateCanQueryRouteState(canShowRoute: Bool) {
        busRouteQueryButton.animateShowing(show: canShowRoute)
    }
    
    // Using autolayout to layout the subviews (map, button, search view, search result)
    private func setupConstraints() {
        var layoutConstraints = [NSLayoutConstraint]()
        // MapView
        layoutConstraints.append(mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        layoutConstraints.append(mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        layoutConstraints.append(mapView.topAnchor.constraint(equalTo: topSearchView.bottomAnchor))
        layoutConstraints.append(mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        // Search bar view
        layoutConstraints.append(topSearchView.topAnchor.constraint(equalTo: view.topAnchor))
        layoutConstraints.append(topSearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        layoutConstraints.append(topSearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        layoutConstraints.append(topSearchView.heightAnchor.constraint(equalToConstant: PETopSearchView.searchViewHeight + UIApplication.shared.topPadding))
        // Search controller view
        layoutConstraints.append(searchResultController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        layoutConstraints.append(searchResultController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        layoutConstraints.append(searchResultController.view.topAnchor.constraint(equalTo: topSearchView.bottomAnchor))
        layoutConstraints.append(searchResultController.view.heightAnchor.constraint(equalToConstant: searchResultViewHeight))
        // Bus route query button
        layoutConstraints.append(busRouteQueryButton.widthAnchor.constraint(equalToConstant: PELoadingButton.loadingButtonSize))
        layoutConstraints.append(busRouteQueryButton.heightAnchor.constraint(equalToConstant: PELoadingButton.loadingButtonSize))
        layoutConstraints.append(busRouteQueryButton.topAnchor.constraint(equalTo: topSearchView.bottomAnchor, constant: UIView.defaultSystemSpacing * 2.0))
        layoutConstraints.append(busRouteQueryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    // Action that will be called when user taps on the bus route button
    // It will call the fetchBusRoute method on the busRouteService which will query all the available bus route between the two locations
    // If there is more than one route, it will show a bus route table that allow user to choose which route they would like to go
    @objc private func didTapBusRouteQueryButton() {
        busRouteQueryButton.userTapped()
        mapView.removeAnnotations(busAnnotations)
        busAnnotations.removeAll()
        busRouteService.fetchBusRoutes(origin: busRoute.startLocation!.coordinate.coordinateString,
                                       destination: busRoute.endLocation!.coordinate.coordinateString) { [weak self] busRoute, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.busRouteQueryButton.finishedLoading()
                if let busRoute = busRoute {
                    self.busRoute.updateRoutes(routes: busRoute)
                    let busRouteTableController = BusRouteTableViewController(busRoutes: self.busRoute.routes)
                    busRouteTableController.delegate = self
                    let navController = UINavigationController(rootViewController: busRouteTableController)
                    self.present(navController, animated: true)
                }
            }
        }
    }
    
}

// Extensions of PEMainViewController, implementing the delegate methods defined in different delegate protocols

extension PEMainViewController: BusRouteTableViewControllerDelegate {
    
    // Reacts to user's selection of a certain bus route between two locations
    func didSelectBusRouteAtIndex(index: Int) {
        busRouteQueryButton.userTapped()
        busRouteService.fetchBusStopsWithRoute(busRoute: busRoute.routes[index]) { [weak self] busStopPositions, error in
            DispatchQueue.main.async {
                if let self = self {
                    if let busStopPositions = busStopPositions {
                        self.busRoute.updateWithBusStops(busStops: busStopPositions, at: index)
                        for busStop in busStopPositions {
                            let coordinate = CLLocationCoordinate2D(latitude: Double(busStop.location.latitude)!, longitude: Double(busStop.location.longitude)!)
                            self.busAnnotations.append(MKMapView.annotationWith(coordinate: coordinate, title: busStop.name, subtitle: nil))
                        }
                        self.mapView.drawPolylineWithRoute(busRoute: self.busRoute.routes[index])
                        self.mapView.addAnnotations(self.busAnnotations)
                    }
                    self.busRouteQueryButton.finishedLoading()
                }
                
            }
        }
    }
}

extension PEMainViewController: MKMapViewDelegate {
    // annotation view used for the pin dropped onto the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Self.pinReuseId)
        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.annotation = annotation
        return pinView
    }
    
    // Map Overlay render for drawing the polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    // Hide the keyboard when user moves the mapview
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        topSearchView.stopEditing()
    }
}

extension PEMainViewController: PETopSearchViewDelegate {
    
    // Reacts to user input on the search bar. Animate showing the search result view
    // Fetch the POI from the location services with the user input string as keywords
    // Display the POIs in the search result view
    func startSearchWithText(keywords: String) {
        let searchView = searchResultController.view
        if searchView!.isHidden {
            searchResultController.view.animateShowing(show: true)
        }
        locationService.searchPlaceWithKeyWords(keywords: keywords, region: mapView.currentRegion) { [weak self] result in
            if let self = self {
                self.searchResultController.updateWithSearchResults(results: result)
            }
        }
    }
    
    // Hide the search result view when this delegate method is called
    func dismissSearchResult() {
        let searchView = searchResultController.view
        if !searchView!.isHidden {
            searchResultController.view.animateShowing(show: false)
        }
    }
}

extension PEMainViewController: PESearchTableViewControllerDelegate {
    
    // Reacts to user's selection of location from the search result view.
    // It will replace the preivous start/end location and update the UI
    func didSelectSearchResult(result: SearchResult) {
        let annotation = MKMapView.annotationWith(location: result.location, title: result.name, subtitle: nil)
        if let selection = topSearchView.currentSelection {
            switch selection {
            case .from:
                if let oldAnnotation = busRoute.startLocation {
                    mapView.removeAnnotation(oldAnnotation)
                }
                busRoute.startLocation = annotation
            case .to:
                if let oldAnnotation = busRoute.endLocation {
                    mapView.removeAnnotation(oldAnnotation)
                }
                busRoute.endLocation = annotation
            }
            mapView.addAnnotation(annotation)
            var annotations = [MKAnnotation]()
            if busRoute.startLocation != nil {
                annotations.append(busRoute.startLocation!)
            }
            if busRoute.endLocation != nil {
                annotations.append(busRoute.endLocation!)
            }
            mapView.showAnnotations(annotations, animated: true)
        }
        topSearchView.updateLocationName(name: result.name, selection: nil)
        searchResultController.view.animateShowing(show: false)
        topSearchView.stopEditing()
    }
}
