//
//  MapViewController.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 12/01/2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate: class {
    var mapView: MKMapView? { get set  }
    func mapViewController(_ controller: MapViewController, didSelected selectedLocation: CLLocation)
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    weak var mapSelectionDelegate: MapViewControllerDelegate?
    var placeMarkDetailsVC: PlaceMarkDetailsViewController!
    
    // MARK:- View's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        addPlaceMarkDetailsView()
        startLocationUpdates()
    }
    
    // MARK:- Location Manager
    func startLocationUpdates() {
        let isAuthorizedWhenInUse = locationManager.authorizationStatus == .authorizedWhenInUse
        isAuthorizedWhenInUse ? locationManager.startUpdatingLocation() : locationManager.stopUpdatingLocation()
    }
    
    // MARK:- methods
    func addPlaceMarkDetailsView() {
        placeMarkDetailsVC = PlaceMarkDetailsViewController.initiate(with: self)
        let placeMarkDetailsView = placeMarkDetailsVC.view!
        placeMarkDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(placeMarkDetailsVC)
        view.addSubview(placeMarkDetailsView)
        traitCollectionDidChange(nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let hSizeClass = traitCollection.horizontalSizeClass
        let vSizeClass = traitCollection.verticalSizeClass
        
        if hSizeClass == .compact && vSizeClass == .regular {
            CR()
        } else if hSizeClass == .compact && vSizeClass == .compact {
            CC()
        } else if hSizeClass == .regular && vSizeClass == .compact  {
            CC()
        } else if hSizeClass == .regular && vSizeClass == .regular {
            CC()
        } else {
            fatalError()
        }
    }
    
    var currentConstraints = [NSLayoutConstraint]()
    
    func CR() {
        guard let placeMarkDetailsView = placeMarkDetailsVC.view else {return}
        let newConstraints = [
            placeMarkDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            placeMarkDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeMarkDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeMarkDetailsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9)
        ]
        NSLayoutConstraint.deactivate(currentConstraints)
        NSLayoutConstraint.activate(newConstraints)
        currentConstraints = newConstraints
    }
    
    func CC() {
        guard let placeMarkDetailsView = placeMarkDetailsVC.view else {return}
        let newConstraints = [
            placeMarkDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            placeMarkDetailsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            placeMarkDetailsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            placeMarkDetailsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1)
        ]
        NSLayoutConstraint.deactivate(currentConstraints)
        NSLayoutConstraint.activate(newConstraints)
        currentConstraints = newConstraints
    }
    
    @discardableResult
    func markSelectedLocation(at point: CGPoint) -> MKAnnotation {
        let selectionCoordinate = coordinate(from: point)
        let selectedPointAnnotation = MKPointAnnotation()
        selectedPointAnnotation.coordinate = selectionCoordinate
        setMap(annotation: selectedPointAnnotation)
        return selectedPointAnnotation
    }
    
    func coordinate(from point: CGPoint) -> CLLocationCoordinate2D {
        return mapView.convert(point, toCoordinateFrom: mapView)
    }
    
    func location(from point: CGPoint) -> CLLocation {
        let locationCoordinate = coordinate(from: point)
        return .init(latitude: locationCoordinate.latitude , longitude: locationCoordinate.longitude)
    }
    
    fileprivate func centerMapView(at location: CLLocation) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
            self.mapView.setCenter(location.coordinate, animated: false)
        }
    }
    
    func setMap(annotation: MKAnnotation) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        centerMapView(at: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
    }
    
    fileprivate func generateSuccessFeedback() {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
    }
    
    // MARK:- Handlers
    
    @IBAction func locationSelectionHandler(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            sender.isEnabled = false
            generateSuccessFeedback()
            let selectionPoint = sender.location(in: mapView)
            markSelectedLocation(at: selectionPoint)
            mapSelectionDelegate?.mapViewController(self, didSelected: location(from: selectionPoint))
        default:
            sender.isEnabled = true
        }
    }
    
    @IBAction func showUserCurrentLocation() {
        guard let location = locationManager.location else {return}
        centerMapView(at: location)
    }
    
    @IBAction func showSelectedPlaceMarkLocation() {
        // remove the user location annotation from place mark annotation
        guard let placeMarkAnnotation = mapView.annotations.map({$0 as? MKPointAnnotation}).compactMap({$0}).first else { return }
        let location = CLLocation(latitude: placeMarkAnnotation.coordinate.latitude, longitude: placeMarkAnnotation.coordinate.longitude)
        centerMapView(at: location)
    }
}

// MARK:- implementing CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            mapSelectionDelegate?.mapViewController(self, didSelected: location)
            // TODO: center the map only if its the first user location update
            centerMapView(at: location)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        } else {
            manager.stopUpdatingLocation()
        }
    }
    
}
