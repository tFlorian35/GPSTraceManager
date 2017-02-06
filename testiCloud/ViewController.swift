//
//  ViewController.swift
//  testiCloud
//
//  Created by Florian Tonnelier on 26/01/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit
import MapKit
import CloudKit
import Foundation


class ViewController: UIViewController, UIDocumentPickerDelegate, XMLParserDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate {
    let locationManager = CLLocationManager()
    @IBOutlet weak var displayMap: MKMapView!
    
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        //Loader
        loader.stopAnimating()
        loader.hidesWhenStopped = true
        
    
    }
   
    private var boundaries = [CLLocationCoordinate2D]()
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        //If I the file GPX file
        var traces = [CLLocationCoordinate2D]()
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            let myFileUrl = url
                do {
                    //contents : contenu de mon fichier
                    let contents = try String(contentsOf: url)
                    let data = contents.data(using: String.Encoding.utf8)
                    
                    do {
                        let xmlDoc = try AEXMLDocument(xml: data!)
                        let nb = (xmlDoc.root["trk"]["trkseg"]["trkpt"].count)
                        print(nb)
                        
                        //Création du tableau de CLLocationCoordinates2D traces
                        for trkpt in xmlDoc.root["trk"]["trkseg"].children{
                            let lat = Double(trkpt.attributes["lat"]!)
                            let lon = Double(trkpt.attributes["lon"]!)
                            traces.append(CLLocationCoordinate2D(latitude: lat!, longitude: lon!))
                            
                            
                            
                            
                            
                        }
                        
                    }
                    catch {
                        print("\(error)")
                    }
                    
                } catch {
                    //Le contenu ne peut pas être chargé 
                    
                
                }
            
            for point in traces{
                loader.stopAnimating()
                loader.hidesWhenStopped = true
                
                //print("Je suis une trace \(point)")
                var anotation = MKPointAnnotation()
                anotation.coordinate = point
                self.displayMap.addAnnotation(anotation)

                
                var geodesic = MKGeodesicPolyline(coordinates: traces, count: traces.count)
                displayMap.add(geodesic)
                
                
                //Ajouter chaque annotation dans la base
                
            }
            func createPolyline(mapView: MKMapView)->MKPolylineRenderer {
                
                var polyline = MKPolyline(coordinates: traces, count: traces.count)
                self.displayMap.add(polyline)
            
                
                let renderer = MKPolylineRenderer(polyline:polyline)
                renderer.lineWidth = 3.0
                renderer.alpha = 0.5
                renderer.strokeColor = UIColor.blue
                let span = MKCoordinateSpanMake(0.01, 0.01)
                let region = MKCoordinateRegion(center: traces[1], span: span)
                self.displayMap.setRegion(region, animated: true)
                
              
            
                return renderer
            }
            
            
            createPolyline(mapView: displayMap)
            
            
            
            
            //print("L'url de mon fichier est \(myFileUrl)")
            
        }
    }

  
    @IBAction func `import` (_ sender: Any) {
        print("OKOK33")

        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.xml"], in: UIDocumentPickerMode.import)
    
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
        documentPicker.delegate = self
        
        loader.startAnimating()
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        loader.stopAnimating()
        
        
        
        let alertController = UIAlertController(title: "Annuler ?", message: "Voulez vous annuler l'import ?", preferredStyle: UIAlertControllerStyle.alert)
        let DestructiveAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            print("Destructive")
        }
        
        let okAction = UIAlertAction(title: "Impotrer une trace", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("Continuer")
            self.`import`(Any)
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
       
        
        
        
        
    }
  


}

