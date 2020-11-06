//
//  ViewController.swift
//  Map_App_Example
//
//  Created by Ali Köse on 6.11.2020.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController , MKMapViewDelegate,CLLocationManagerDelegate{

    // First Step: import mapkit library and delegate MKMapViewDelegate  write didload mapview.delegate and you will see to map on your app view
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // but spend a lot of battery for best location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    @objc func selectLocation(gestureRecognizer : UILongPressGestureRecognizer){ // we need to use gesture methods
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self.mapView)
            let pointCoordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = pointCoordinate
            annotation.title = "New Annotation"
            annotation.subtitle = "Map_Example"
            self.mapView.addAnnotation(annotation)
        }
      
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }


}

