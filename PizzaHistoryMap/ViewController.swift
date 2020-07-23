//
//  ViewController.swift
//  PizzaHistoryMap
//
//  Created by Moideen Nazaif VM on 17/07/20.
//  Copyright © 2020 Moideen Nazaif VM. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    var coordinate2D = CLLocationCoordinate2DMake(40.8367321,14.2468856)
    var camera = MKMapCamera()
    var pitch = 0
    var isOn = false
    
    //MARK: Outlets
    @IBOutlet weak var changeMapType: UIButton!
    @IBOutlet weak var changePitch: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.addAnnotations(PizzaHistoryAnnotations().annotations)
        updateMapRegion(rangeSpan: 100)
    }
    
    
    //MARK: - Actions
    @IBAction func changeMapType(_ sender: UIButton) {
        switch mapView.mapType {
        case .standard:
            mapView.mapType = .satellite
            
        case .satellite:
            mapView.mapType = .hybrid
            
        case .hybrid:
            mapView.mapType = .satelliteFlyover
            
        case .satelliteFlyover:
            mapView.mapType = .hybridFlyover
            
        case .hybridFlyover:
            mapView.mapType = .standard
        default:
            mapView.mapType = .standard
        }
    }
    
    @IBAction func changePitch(_ sender: UIButton) {
        pitch = (pitch + 15) % 90
        sender.setTitle("\(pitch) º", for: .normal)
        mapView.camera.pitch = CGFloat(pitch)
    }
    
    @IBAction func toggleMapFeatures(_ sender: UIButton) {
//        mapView.showsBuildings = isOn
//        isOn = !isOn
        isOn = !mapView.showsPointsOfInterest
        mapView.showsPointsOfInterest = isOn
        mapView.showsScale = isOn
        mapView.showsTraffic = isOn
        mapView.showsCompass = isOn
    }
    
    @IBAction func findHere(_ sender: UIButton) {
    }
    
    @IBAction func findPizza(_ sender: UIButton) {
    }
    
    @IBAction func locationPicker(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
//        mapView.removeAnnotations(mapView.annotations)
        switch index {
        case 0: // Naples
            coordinate2D = CLLocationCoordinate2DMake(40.8367321,14.2468856)
        case 1: // New York
            coordinate2D = CLLocationCoordinate2DMake(40.7216294 , -73.995453)
            updateMapCamera(heading: 245, altitude: 250)
//            let pizzaPin = PizzaAnnotation(coordinate: coordinate2D, title: "New York Pizza", subtitle: "Pizza comes to America")
//            mapView.addAnnotation(pizzaPin)
            return
        case 2: //  Chicago
            coordinate2D = CLLocationCoordinate2DMake(41.892479 , -87.6267592)
            updateMapCamera(heading: 12, altitude: 2)
            return
        case 3: //  Chatham
            coordinate2D = CLLocationCoordinate2DMake(42.4056555,-82.1860369)
            updateMapCamera(heading: 180, altitude: 1000)
            return
        case 4: //  Beverly Hills
            coordinate2D = CLLocationCoordinate2DMake(34.0674607,-118.3977309)
//            let pizzaPin = MKPointAnnotation()
//            pizzaPin.coordinate = coordinate2D
//            pizzaPin.title = "Fusion Cuisine Pizza"
//            pizzaPin.subtitle = "Also known as California Pizza"
//            mapView.addAnnotation(pizzaPin)
        default:
            coordinate2D = CLLocationCoordinate2DMake(34.0674607,-118.3977309)
        }
        updateMapRegion(rangeSpan: 100)
    }
    
    func updateMapRegion(rangeSpan: CLLocationDistance) {
        let region = MKCoordinateRegion.init(center: coordinate2D, latitudinalMeters: rangeSpan, longitudinalMeters: rangeSpan)
        mapView.region = region
    }
    
    func updateMapCamera(heading: CLLocationDirection, altitude: CLLocationDistance) {
        camera.centerCoordinate = coordinate2D
        camera.heading = heading
        camera.altitude = altitude
        camera.pitch = 0
        changePitch.setTitle("", for: .normal)
        mapView.camera = camera
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKPinAnnotationView()
        guard let annotation = annotation as? PizzaAnnotation else {
            return nil
        }
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) as? MKPinAnnotationView {
            annotationView = dequedView
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
        }
        annotationView.pinTintColor = UIColor.blue
        annotationView.canShowCallout = true
        let paragraph = UILabel()
        paragraph.numberOfLines = 0
        paragraph.font = UIFont.preferredFont(forTextStyle: .caption1)
        paragraph.text = annotation.historyText
        annotationView.detailCalloutAccessoryView = paragraph 
        return annotationView
    }
}

