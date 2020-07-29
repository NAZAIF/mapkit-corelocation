//
//  PizzaAnnotation.swift
//  PizzaHistoryMap
//
//  Created by Moideen Nazaif VM on 18/07/20.
//  Copyright © 2020 Moideen Nazaif VM. All rights reserved.
//

import Foundation
import MapKit

class PizzaAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var identifier = "Pin"
    var historyText = ""
    var pizzaPhoto: UIImage? = nil
    var deliveryRadius: CLLocationDistance! = nil
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
}
