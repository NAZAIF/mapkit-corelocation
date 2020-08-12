//
//  ViewController.swift
//  PizzaHistoryMap
//
//  Created by Moideen Nazaif VM on 17/07/20.
//  Copyright © 2020 Moideen Nazaif VM. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var coordinate2D = CLLocationCoordinate2DMake(40.8367321,14.2468856)
    var camera = MKMapCamera()
    var pitch = 0
    var isOn = false
    var heading = 0.0
    let onRampCoordinate = CLLocationCoordinate2DMake(37.33458564, -122.035293)
    var locationManager = CLLocationManager()
    
    //MARK: Outlets
    @IBOutlet weak var changeMapType: UIButton!
    @IBOutlet weak var changePitch: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        mapView.addAnnotations(PizzaHistoryAnnotations().annotations)
        addDeliveryOverlay()
        addPolyLines()
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
        disableLocationServices()
        //        mapView.showsBuildings = isOn
        //        isOn = !isOn
        isOn = !mapView.showsPointsOfInterest
        mapView.showsPointsOfInterest = isOn
        mapView.showsScale = isOn
        mapView.showsTraffic = isOn
        mapView.showsCompass = isOn
    }
    
    @IBAction func findHere(_ sender: UIButton) {
        setupCoreLocation()
    }
    
    @IBAction func findPizza(_ sender: UIButton) {
        let address = "2121 North. Clark St. IL"
        getCoordinates(address: address) { (coordinate, location, error) in
            if let coordinate = coordinate {
                self.mapView.camera.centerCoordinate = coordinate
                self.mapView.camera.altitude = 1000
                let pin = PizzaAnnotation(coordinate: coordinate, title: address, subtitle: location)
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    @IBAction func locationPicker(_ sender: UISegmentedControl) {
        disableLocationServices()
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
            updateMapCamera(heading: 0, altitude: 15000)
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
            updateMapCamera(heading: 0, altitude: 1500)
            return
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
        var annotationView = MKAnnotationView()
        guard let annotation = annotation as? PizzaAnnotation else {
            return nil
        }
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) {
            annotationView = dequedView
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
        }
        
        annotationView.image = UIImage(named: "pizza pin")
        annotationView.canShowCallout = true
        let paragraph = UILabel()
        paragraph.font = UIFont.preferredFont(forTextStyle: .caption1)
        paragraph.text = annotation.subtitle
        paragraph.numberOfLines = 1
        paragraph.adjustsFontSizeToFitWidth = true
        annotationView.detailCalloutAccessoryView = paragraph
        annotationView.leftCalloutAccessoryView = UIImageView(image: annotation.pizzaPhoto)
        annotationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let vc = AnnotationDetailViewController(nibName: "AnnotationDetailViewController", bundle: nil)
        vc.annotation = view.annotation as! PizzaAnnotation
        present(vc, animated: true, completion: nil)
    }
    
    //    Adds polylines connecting all annotations
    func addPolyLines() {
        let annotations = PizzaHistoryAnnotations().annotations
        let bhpolyLine = MKPolyline(coordinates: annotations.map({ (annotation) -> CLLocationCoordinate2D in
            annotation.coordinate
        }), count: annotations.count)
        bhpolyLine.title = "All_Restaurants_Line"
        mapView.addOverlays([bhpolyLine])
    }
    
    func addDeliveryOverlay() {
        //        let radius = 1600.0 //meters
        for location in mapView.annotations {
            if let radius = (location as! PizzaAnnotation).deliveryRadius {
                let circle = MKCircle(center: location.coordinate, radius: radius)
                mapView.addOverlay(circle)
            }
            
        }
    }
    
    func setupCoreLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
            
        case .authorizedAlways:
            enableLocationServices()
        default:
            break
        }
    }
    
    func enableLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.setUserTrackingMode(.follow, animated: true)
        }
        
        if CLLocationManager.headingAvailable() { // check if magnetometer is available
            locationManager.startUpdatingHeading()
        } else {
            print("heading not available")
        }
        monitorRegion(center: onRampCoordinate, radius: 100, id: "On ramp")
    }
    
    func disableLocationServices() {
        locationManager.stopUpdatingLocation()
    }
    
    func monitorRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance, id: String) {
        // Since geofencing works in background, it needs always on status
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("always authorized 11223")
            // region monitoring is unavailable in some devices
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                print("monitoring available 11223")
                let region = CLCircularRegion(center: center, radius: radius, identifier: id)
                region.notifyOnExit = true
                region.notifyOnEntry = true
                locationManager.startMonitoring(for: region)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyLine = overlay as? MKPolyline {
            let polyLineRenderer = MKPolylineRenderer(polyline: polyLine)
            polyLineRenderer.strokeColor = .red
            polyLineRenderer.lineWidth = 5.0
            polyLineRenderer.lineDashPattern = [20,10,2,10]
            return polyLineRenderer
        }
        if let circle = overlay as? MKCircle { //succeed if it is a circle
            let circleRenderer = MKCircleRenderer(circle: circle)
            circleRenderer.fillColor = .init(red: 0, green: 0.1, blue: 0.1, alpha: 0.1)
            circleRenderer.strokeColor = .blue
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let circularRegion = region as! CLCircularRegion
        if circularRegion.identifier == "On ramp" {
            let alert = UIAlertController(title: "Pizza History", message: "You are on the ramp", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let circularRegion = region as! CLCircularRegion
        if circularRegion.identifier == "On ramp" {
            let alert = UIAlertController(title: "Pizza History", message: "You are out of the ramp", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("authorized")
            
        case .denied, .restricted:
            print("Not authorized")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        coordinate2D = location.coordinate
        let speedString = "\(location.speed * 2.23694) mph"
        let headingString = " Heading: \(heading)º"
        let courseString = headingString + " at " + speedString
        print(courseString)
        let displayString = "\(location.timestamp) Coord:\(coordinate2D) Alt: \(location.altitude) meters"
        print(displayString)
        updateMapRegion(rangeSpan: 200)
        let pizzaPin = PizzaAnnotation(coordinate: coordinate2D, title: displayString, subtitle: "")
        mapView.addAnnotation(pizzaPin)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
    }
    
    func getCoordinates(address: String, completionHandler: @escaping (CLLocationCoordinate2D?, String, NSError?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let coordinate = placemark.location?.coordinate
                    let location = placemark.locality! + " " + placemark.isoCountryCode!
                    completionHandler(coordinate, location, nil)
                    return
                }
            }
            completionHandler(nil, "", error as NSError?)
        }
    }
}

