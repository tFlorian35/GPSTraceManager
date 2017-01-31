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
                    //print(contents)
                    //Import an XML document
                    //guard let url = Bundle.main.url(forResource: "books", withExtension: "xml") else { return }
                    //guard let xml = XML(contentsOf: contents) else { return }
                    let myXmlFile = XML2(data: data!)
                    
                    print(trkptNode)
                                       /*
                    func getPolygons() -> [MKPolygon]?{
                        var polyList:[MKPolygon] = [MKPolygon]()
                        boundaries = [CLLocationCoordinate2D]()
                        let filePath = myFileUrl
                        if filePath == nil {
                            print ("Impossible d'accéder au fichier")
                
                        }
                        let data = contents.data(using: String.Encoding.utf8)
                        let parser = XMLParser(data: data!)
                        let success = parser.parse()
                        
                        if !success{
                            print("Impossible de parser le fichier GPX")
                        }
                        print("Je parse.............")
                        polyList.append(MKPolygon(coordinates: boundaries, count: boundaries.count))
                        
                        //print("Test : \(polyList[0])")
                        
                        for polygon in polyList{
                            print("Je suis un point : \(polygon)")
                        }
                        return polyList
                        
                        
                    }
                    getPolygons()*/
                
                    
                    /*
                    func parser(parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
                        //Only check for the lines that have a <trkpt> or <wpt> tag. The other lines don't have coordinates and thus don't interest us
                        if elementName == "trkpt" || elementName == "wpt" {
                            //Create a World map coordinate from the file
                            let lat = attributeDict["lat"]!
                            let lon = attributeDict["lon"]!
                            print(lat)
                            boundaries.append(CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(lon)!))
                        }
                    }*/
                    
                    
                    
                    
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

