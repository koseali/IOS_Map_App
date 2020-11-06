//
//  ViewController.swift
//  Map_App_Example
//
//  Created by Ali Köse on 6.11.2020.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController , MKMapViewDelegate,CLLocationManagerDelegate{

    // First Step: import mapkit library and delegate MKMapViewDelegate  write didload mapview.delegate and you will see to map on your app view
    var locationManager = CLLocationManager()
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locnameText: UITextField!
    @IBOutlet weak var favnoteText: UITextField!
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
            choosenLongitude = pointCoordinate.longitude
            choosenLatitude = pointCoordinate.latitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = pointCoordinate
            annotation.title = locnameText.text
            annotation.subtitle = favnoteText.text
            self.mapView.addAnnotation(annotation)
        }
      
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(locnameText.text, forKey: "title")
        newPlace.setValue(favnoteText.text, forKey: "subtitle")
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(choosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        do {
            try context.save()
            print("KAydetti")
        } catch   {
            print("Hata")
        }
        
    }
    
}

