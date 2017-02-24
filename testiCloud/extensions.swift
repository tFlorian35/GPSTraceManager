//
//  extensions.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 24/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//


import UIKit
import MapKit
import CloudKit
import Foundation

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay);
        pr.strokeColor = UIColor.red
        pr.lineWidth = 5;
        return pr;
    }
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
