//
//  AnnotationDetailViewController.swift
//  PizzaHistoryMap
//

import UIKit
import CoreLocation

class AnnotationDetailViewController: UIViewController {
    var annotation:PizzaAnnotation!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pizzaPhoto: UIImageView!
    @IBOutlet weak var historyText: UITextView!
    
    @IBAction func done(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func placemark(annotation: PizzaAnnotation, completionHandler: @escaping (CLPlacemark?) -> Void) {
        let coordinate = annotation.coordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemarks = placemarks {
                completionHandler(placemarks.first)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = annotation.title
        pizzaPhoto.image = annotation.pizzaPhoto
        
        placemark(annotation: annotation) { (placemark) in
            if let placemark = placemark {
                var locationString = ""
                if let city = placemark.locality {
                    locationString += city + " "
                }
                if let state = placemark.administrativeArea {
                    locationString += state + " "
                }
                if let country = placemark.country {
                    locationString += country
                }
                self.historyText.text = locationString + "\n\n" + self.annotation.historyText
            } else {
                print("Placemark not found")
                self.historyText.text = self.annotation.historyText
                
            }
        }
    }
    
    
    
}
