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

class ViewController: UIViewController, UIDocumentPickerDelegate, XMLParserDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var displayMap: MKMapView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    
    @IBOutlet weak var UserTraceName: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerViewDate: UIDatePicker!
    
    
    @IBOutlet weak var testImg: UIImageView!
    
    var DBSportList = [SportClass]()

    let locationManager = CLLocationManager()
    
    //CK needs CLLocation only
    var CLLocTrace = [CLLocation]()
    
    func createSportTab(){
    
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Sport", predicate: predicate)
        
        let op = CKQueryOperation(query: query)
        op.desiredKeys = ["SDesiniation"]
        var newSports = [SportClass]()
        
        op.recordFetchedBlock = {record in
            let lesSports = SportClass()
            lesSports.SDesiniation = record["SDesiniation"] as! String!
            
            newSports.append(lesSports)
            
        }
        
        op.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.DBSportList = newSports
                    if self.pickerView != nil{
                        self.pickerView.reloadAllComponents()
                    }
                
                    
                }else{
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of whistles; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
        
        //Operation on the public DB
        CKContainer.default().publicCloudDatabase.add(op)
        
        
    }
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSportTab()
        
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
    
    //Implément the picker viex with sport tab fom CK
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(self.DBSportList[row].SDesiniation)
        return self.DBSportList[row].SDesiniation
        
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.DBSportList.count
        
    }
    
    
    private func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) -> String? {
        
        let selectedValue = self.DBSportList[row].SDesiniation
        print(selectedValue)
        return selectedValue
    }
    

    
    
    
    
    var boundaries = [CLLocationCoordinate2D]()
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        //If it is a .gpx file
    
        var traces = [CLLocationCoordinate2D]()
        
        
        
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            let myFileUrl = url
                do {
                    //contents : all the gpx file
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
                    //Can't load content (if this is a .gpx but content is =! GPX)
                    
                
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
            let medianeTab : Int = (traces.count)/2
            let region = MKCoordinateRegion(center: traces[medianeTab], span: span)
            displayMap.setRegion(region, animated: true)
            
            let alertController = UIAlertController(title: "Info", message: "Pour un meilleur rendu, ajustez manuellement la trace à l'écran de manière la la voir entièrement", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                //ok
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            
        }
        
}
    
    @IBAction func UserValidImport(_ sender: Any) {
        
        //Capture d'écran de la map
        UIGraphicsBeginImageContextWithOptions(CGSize(width: displayMap.bounds.size.width,height: displayMap.bounds.size.height), false, 0);
        
        let myRect = CGRect(x: 0, y: 0, width: displayMap.bounds.size.width, height: displayMap.bounds.size.height)
        self.displayMap.drawHierarchy(in: myRect, afterScreenUpdates: true)
        let imageTrace:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        //Je sauvegarde l'image temporairement afin de lui atribuer une URL pour sauvegarde dans CK
        let tmpImageTrace = UIImageJPEGRepresentation(imageTrace, 0.5)
        let tmpImageTraceUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
        do{
            try tmpImageTrace!.write(to: tmpImageTraceUrl!)
        
        }catch let error as NSError{
            print("error \(error)")
            return
        }
        
        
        self.self.testImg.image = imageTrace
        
        
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //DEC : Date
        var TDate : String = ""
        if pickerViewDate != nil{
            _ = pickerViewDate.datePickerMode = UIDatePickerMode.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            TDate = dateFormatter.string(from: pickerViewDate.date)
        }
        
        
        let delegate: UIPickerViewDelegate? = pickerView?.delegate
        let titleOptional: String? = delegate?.pickerView!(pickerView, titleForRow: pickerView.selectedRow(inComponent: 0), forComponent: 0)
        let pickerValue = titleOptional
        
        
        
        
        if segue.identifier == "ViewControllerAssocEquipements"{
            
            
            
            // get a reference to the second view controller
            let secondViewController = segue.destination as! ViewControllerAssocEquipements
            // set a variable in the second view controller with the String to pass
            secondViewController.traceName = UserTraceName.text!
            secondViewController.traceDate = TDate as String!
            secondViewController.traceSport = pickerValue as String!
            secondViewController.traceImage = self.testImg.image!
        }
        
        
        
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
            self.`import`(Any.self)
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
       
    }
    
    
  


}

