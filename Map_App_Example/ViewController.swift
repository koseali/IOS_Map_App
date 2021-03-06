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
    
    
    var selectPlace = ""
    var selectid : UUID?
    
    
    
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
        
        if selectPlace != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            request.returnsObjectsAsFaults = false
            let idString = selectid!.uuidString
            request.predicate = NSPredicate(format: "id = %@", idString)
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String{
                            locnameText.text = title
                            
                            if let subtitle = result.value(forKey: "subtitle") as? String{
                                favnoteText.text = subtitle
                                
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    choosenLatitude = latitude
                                    
                                    if let longitude  = result.value(forKey: "longitude") as? Double{
                                        choosenLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        let coordinate = CLLocationCoordinate2D(latitude: choosenLatitude, longitude: choosenLongitude)
                                        annotation.title = title
                                        annotation.subtitle = subtitle
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }catch  {
                print("Error read to loc.")
            }
            
           
        }
        
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
        if selectPlace == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }else{
            //do nothing
            }
      
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black // rengini pinview özelleştirme
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }else{
            pinView?.annotation = annotation
        }
        
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectPlace != ""{
            let newLocation = CLLocation(latitude: choosenLatitude, longitude: choosenLongitude)
            CLGeocoder().reverseGeocodeLocation(newLocation) { (placeMark, error) in
                // closure Call back function
                // Navigation need to mapItem. Mapitem need to PlaceMark object.
                // PlaceMark take it to reverseGeoCode method
                if let placemark = placeMark {
                    if placemark.count > 0 {
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        let annotationTitle = self.locnameText.text
                        item.name = annotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
                
            }
            
        }
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
            print("Save Success")
        } catch   {
            print("Saving Error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
    
}

