//
//  MapViewController.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 12/01/2021.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var placeMarkDetailsVC: PlaceMarkDetailsViewController!
    let locationManager = CLLocationManager()
    
    // MARK:- View's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlaceMarkDetailsView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestLocationAuth()
    }
    
    // MARK:- Location Manager
    func requestLocationAuth() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK:- methods
    func addPlaceMarkDetailsView() {
        placeMarkDetailsVC = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaceMarkDetailsViewController") as! PlaceMarkDetailsViewController)
        let placeMarkDetailsView = placeMarkDetailsVC.view!
        placeMarkDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(placeMarkDetailsVC)
        view.addSubview(placeMarkDetailsView)
        NSLayoutConstraint.activate([
            placeMarkDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            placeMarkDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeMarkDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeMarkDetailsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9)
        ])
        
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
    
    func setMap(annotation: MKAnnotation) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
            self.mapView.setCenter(annotation.coordinate, animated: false)
        }
    }
    
    func reversGeocode(for location: CLLocationCoordinate2D) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(.init(latitude: location.latitude, longitude: location.longitude), completionHandler: handleRevereseGecodingResponse)
    }

    lazy var handleRevereseGecodingResponse: ([CLPlacemark]? , Error?) -> () = { [weak self] (placeMarks, responseError) in
        
    }
    
    // MARK:- Handlers
    @IBAction func locationSelectionHandler(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            sender.isEnabled = false
            
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.notificationOccurred(.success)
            
            let selectionPoint = sender.location(in: mapView)
            markSelectedLocation(at: selectionPoint)
        default:
            sender.isEnabled = true
        }
    }
}
