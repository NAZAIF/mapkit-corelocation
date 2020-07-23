//
//  AnnotationDetailViewController.swift
//  PizzaHistoryMap
//

import UIKit

class AnnotationDetailViewController: UIViewController {
    var annotation:PizzaAnnotation!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pizzaPhoto: UIImageView!
    @IBOutlet weak var historyText: UITextView!
    
    @IBAction func done(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = annotation.title
        pizzaPhoto.image = annotation.pizzaPhoto
        historyText.text = annotation.historyText
        // Do any additional setup after loading the view.
    }

    

}
