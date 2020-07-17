//
//  ViewController.swift
//  PizzaHistoryMap
//
//  Created by Moideen Nazaif VM on 17/07/20.
//  Copyright © 2020 Moideen Nazaif VM. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    var coordinate2D = CLLocationCoordinate2DMake(40.8367321,14.2468856)
    
    //MARK: Outlets
    @IBOutlet weak var changeMapType: UIButton!
    @IBOutlet weak var changePitch: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMapRegion(rangeSpan: 100)
    }
    
    
    //MARK: - Actions
    @IBAction func changeMapType(_ sender: UIButton) {
    }
    
    @IBAction func changePitch(_ sender: UIButton) {
        
    }
    
    @IBAction func toggleMapFeatures(_ sender: UIButton) {
    }
    
    @IBAction func findHere(_ sender: UIButton) {
    }
    
    @IBAction func findPizza(_ sender: UIButton) {
    }
    
    @IBAction func locationPicker(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            coordinate2D = CLLocationCoordinate2DMake(40.8367321,14.2468856)
        case 1:
            coordinate2D = CLLocationCoordinate2DMake(40.7216294 , -73.995453)
        case 2:
            coordinate2D = CLLocationCoordinate2DMake(41.892479 , -87.6267592)
        case 3:
            coordinate2D = CLLocationCoordinate2DMake(42.4056555,-82.1860369)
        case 4:
            coordinate2D = CLLocationCoordinate2DMake(34.0674607,-118.3977309)
        default:
            coordinate2D = CLLocationCoordinate2DMake(34.0674607,-118.3977309)
        }
        updateMapRegion(rangeSpan: 100)
    }
    
    func updateMapRegion(rangeSpan: CLLocationDistance) {
        let region = MKCoordinateRegion.init(center: coordinate2D, latitudinalMeters: rangeSpan, longitudinalMeters: rangeSpan)
        mapView.region = region
    }
}

