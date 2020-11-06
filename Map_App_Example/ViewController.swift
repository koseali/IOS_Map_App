//
//  ViewController.swift
//  Map_App_Example
//
//  Created by Ali Köse on 6.11.2020.
//

import UIKit
import MapKit
class ViewController: UIViewController , MKMapViewDelegate{

    // First Step: import mapkit library and delegate MKMapViewDelegate  write didload mapview.delegate and you will see to map on your app view
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }


}

