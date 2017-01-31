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



class ViewController: UIViewController, UIDocumentPickerDelegate, XMLParserDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        
    }
    
    
    private var boundaries = [CLLocationCoordinate2D]()
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        //If I the file GPX file
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            let myFileUrl = url
                do {
                    //content : read the content of my file
                    let contents = try String(contentsOf: url)
                    let data = contents.data(using: String.Encoding.utf8)
                    
                    do {
                        let xmlDoc = try AEXMLDocument(xml: data!)
                        
                     
                        print("-----------------------------------")
                        
                    
                      
                        var nb = xmlDoc.root["trk"]["trkseg"]["trkpt"].count
                    
                        print(nb)
                        for trkpt in xmlDoc.root["trk"]["trkseg"].children{
                            //print(xmlDoc.root["trk"]["trkseg"]["trkpt"].attributes!)
                            //print(xmlDoc.root["trk"]["trkseg"]["trkpt"].attributes["lon"]!)
                            for i in 0...nb{
                                print(xmlDoc.root["trk"]["trkseg"].children[i].attributes["lat"]!)
                                print(xmlDoc.root["trk"]["trkseg"].children[i].attributes["lon"]!)
                            }
                        }
                        
                     
                        
                        
                        
                        
                        
                        
                        print("-----------------------------------")
                        
                        
                    }
                    catch {
                        print("\(error)")
                    }
                    
                } catch {
                    //content could not be loaded
                }
            
            
            
            
            //print("L'url de mon fichier est \(myFileUrl)")
            
        }
    }

  
    @IBAction func `import`(_ sender: Any) {
        print("OKOK33")

        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.xml"], in: UIDocumentPickerMode.import)
    
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
        documentPicker.delegate = self
        
    }
  


}

