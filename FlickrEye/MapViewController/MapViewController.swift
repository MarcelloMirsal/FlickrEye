//
//  MapViewController.swift
//  FlickrEye
//
//  Created by Marcello Mirsal on 12/01/2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK:- View's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlaceMarkDetailsView()
    }
    
    func addPlaceMarkDetailsView() {
        let placeMarkDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaceMarkDetailsViewController") as! PlaceMarkDetailsViewController
        placeMarkDetailsVC.mapViewController = self
        let placeMarkDetailsView = placeMarkDetailsVC.view!
        placeMarkDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(placeMarkDetailsVC)
        view.addSubview(placeMarkDetailsView)
        NSLayoutConstraint.activate([
            placeMarkDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            placeMarkDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeMarkDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeMarkDetailsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8)
        ])
        
    }
    
    @discardableResult
    func selectLocation(at point: CGPoint) -> MKAnnotation {
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
    
    
    // MARK:- Handlers
    @IBAction func locationSelectionHandler(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            sender.isEnabled = false
            let selectionPoint = sender.location(in: mapView)
            selectLocation(at: selectionPoint)
            
        default:
            sender.isEnabled = true
        }
    }
}
