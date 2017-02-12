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

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay);
        pr.strokeColor = UIColor.red
        pr.lineWidth = 5;
        return pr;
    }
}


class ViewController: UIViewController, UIDocumentPickerDelegate, XMLParserDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var displayMap: MKMapView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var UserTraceName: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SetUp Location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        
        
        if loader != nil {
            //Loader
            loader.stopAnimating()
            loader.hidesWhenStopped = true
        }
        
        
        if pickerView != nil {
            //Delegate pickerview to self
            pickerView.delegate = self
            pickerView.dataSource = self
        }
        
        
    }
    
    
    let locationManager = CLLocationManager()
    
    var CLLocTrace = [CLLocation]()
    
    
    var sport = ["Tannis", "Marche", "Course", "Surf", "Kite"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sport[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sport.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let selectedValue = sport[row]
        print(selectedValue)
    }

    
    
    
    
    
    
    private var boundaries = [CLLocationCoordinate2D]()
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        //If it is a .gpx file
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
                            CLLocTrace.append(CLLocation(latitude: lat!, longitude: lon!))
                            
                            
                        }
                        
                    }
                    catch {
                        print("\(error)")
                    }
                    
                } catch {
                    //Le contenu ne peut pas être chargé 
                    
                
                }
            //Create a point for each line of traces[] (tab of CLLocationCoordinates2D)
            for point in traces{
                
                let anotation = MKPointAnnotation()
                anotation.coordinate = point
                
            }
            
            //Trace the route when the .gpx file is loaded
            func traceRoute(coordinates: [CLLocationCoordinate2D]) {
                let polyLine = MKPolyline(coordinates: traces, count: traces.count)
                self.displayMap.add(polyLine, level: MKOverlayLevel.aboveRoads)
                displayMap.delegate = self
            }
            traceRoute(coordinates: traces)
            loader.stopAnimating()
            loader.hidesWhenStopped = true
            /************
             Zoomer sur le point du milieu de trace
             *************/
            
            let span = MKCoordinateSpanMake(0.050, 0.050)
            let region = MKCoordinateRegion(center: traces[0], span: span)
            displayMap.setRegion(region, animated: true)
         
            
        }
        
       
        
        
    }
    
    
    @IBAction func UserValidImport(_ sender: Any) {
        print("OKImportSucess")
        print(CLLocTrace)
        /*************
        Ajout d'un tableau de trace a la bdd
        *************/
        let uniqueId = arc4random_uniform(99999)
        
        let database = CKContainer.default().publicCloudDatabase
    
        let TraceTitre = UserTraceName.text as! CKRecordValue
        let TabAsCK = CLLocTrace as CKRecordValue
    
        let TestRecordID = CKRecordID(recordName: "RecordN\(uniqueId)")
        let newTrace = CKRecord(recordType: "Trace", recordID: TestRecordID)
    
        newTrace["TTitre"] = TraceTitre
        newTrace["TTrace"] = TabAsCK
    
        database.save(newTrace, completionHandler: { (record:CKRecord?, error:Error?) -> Void in
            if error != nil{
                print("Record OK \(record)")
            }
        })
    }
  
    @IBAction func `import` (_ sender: Any) {
       
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
        }
        
        let okAction = UIAlertAction(title: "Impotrer une trace", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            self.`import`(Any)
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
       
    }
    
    
  


}

