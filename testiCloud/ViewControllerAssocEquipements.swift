//
//  ViewControllerAssocEquipements.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 26/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit
import CloudKit

class ViewControllerAssocEquipements: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var nomTrace: UILabel!
    @IBOutlet weak var dateTrace: UILabel!
    @IBOutlet weak var sportTrace: UILabel!
    @IBOutlet weak var imageTrace: UIImageView!
    @IBOutlet weak var tableViewSelectSport: UITableView!
    
    
    
    var traceName:String = ""
    var traceDate:String = ""
    var traceSport:String = ""
    var traceImage:UIImage? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEquipements()
        
        tableViewSelectSport.delegate = self
        tableViewSelectSport.dataSource = self
        
        // Used the text from the First View Controller to set the label
        nomTrace.text = traceName
        dateTrace.text = traceDate
        sportTrace.text = traceSport
        imageTrace.image = traceImage
        
        
    }
    
    var DBTabEquipements = [EquipementsClass]()
    //Load the equipements from the database
    func loadEquipements(){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Equipement", predicate: predicate)
        
        let op = CKQueryOperation(query: query)
        op.desiredKeys = ["Ecommentaire", "EdateAchat", "Edesignation", "Eetat", "Eimage"]
        var newEquipement = [EquipementsClass]()
        
        op.recordFetchedBlock = {record in
            let lesEquipements = EquipementsClass()
            lesEquipements.recordID = record.recordID
            
            lesEquipements.Ecommentaire = record["Ecommentaire"] as! String!
            lesEquipements.EdateAchat = record["EdateAchat"] as! String!
            lesEquipements.Edesignation = record.value(forKey: "Edesignation") as! String?
            lesEquipements.Eetat = record["Eetat"] as! String!
            
            
            if let photoAsset = record.value(forKey: "Eimage") as? CKAsset{
                lesEquipements.Eimage = UIImage(data: NSData(contentsOf: photoAsset.fileURL)! as Data)
            }
            
            
            
            newEquipement.append(lesEquipements)
            
            
        }
        
        op.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    //ViewController.isDirty = false
                    self.DBTabEquipements = newEquipement
                    self.tableViewSelectSport.reloadData()
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
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print ("Il y a \(self.DBTabEquipements.count) équipements dans la base")
        return self.DBTabEquipements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellA = tableViewSelectSport.dequeueReusableCell(withIdentifier: "CellA", for: indexPath) as! TableViewCellAssocEquipement
        
        cellA.eqptName.text = DBTabEquipements[indexPath.row].Edesignation
        cellA.eqptImage.image = DBTabEquipements[indexPath.row].Eimage
        
        
        //Design
        /*
        cellA.selectionStyle = .none
        
        cellA.contentView.backgroundColor = UIColor.clear
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 180))
        
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cellA.contentView.addSubview(whiteRoundedView)
        cellA.contentView.sendSubview(toBack: whiteRoundedView)
        */
        return cellA
    }
    
    var tab = [String]()
    var i : Int = 0

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let add = UITableViewRowAction(style: .normal, title: "Ajouter") {action, index in
           
            print("Add pressed")
            let recName = self.DBTabEquipements[indexPath.row].Edesignation!
            self.tab.insert(recName, at: self.i)
            self.i = self.i+1
            self.view.makeToast("Equipement \"\(recName)\" importé")
    
        }
        
        let dell = UITableViewRowAction(style: .destructive, title: "Supprimer") {action, index in
           
            print("Delete pressed")
            let recName = self.DBTabEquipements[indexPath.row].Edesignation!
            self.tab = self.tab.filter{$0 != recName}
            self.view.makeToast("Equipement \"\(recName)\" supprimé")
            //self.tab.remove(at: self.i)
            
        }
        
        return [add, dell]
        
    }
    
    
    @IBAction func importTrace(_ sender: Any) {
       
        /*************
         Ajout d'un tableau de trace a la bdd
         *************/
        _ = arc4random_uniform(99999)
        
        let database = CKContainer.default().publicCloudDatabase
        //let TabAsCK = CLLocTrace as CKRecordValue
        
        let TTitre:String = nomTrace.text!
        let TDate:String = dateTrace.text!
        let TSport:String = sportTrace.text!
        let TEquipements:Array = tab
        
        let TraceTitre = TTitre as CKRecordValue?
        let TraceDate = TDate as CKRecordValue!
        let TraceImage = imageTrace.image!
        let TraceSport = TSport as CKRecordValue!
        let TraceEquipements = TEquipements as CKRecordValue!
        

        
        
        //Je sauvegarde l'image temporairement afin de lui atribuer une URL pour sauvegarde dans CK
        
        let tmpImageTrace = UIImageJPEGRepresentation(TraceImage, 1)
        let tmpImageTraceUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
        do{
            try tmpImageTrace!.write(to: tmpImageTraceUrl!)
            
        }catch let error as NSError{
            print("error \(error)")
            return
        }

        //let TestRecordID = CKRecordID(recordName: "RecordN\(uniqueId)")
        let TestRecordID = CKRecordID(recordName: TraceTitre as! String)
        let newTrace = CKRecord(recordType: "Trace", recordID: TestRecordID)
        
        //newTrace["TTrace"] = TabAsCK
        
        newTrace["TTitre"] = TraceTitre!
        newTrace["TDate"] = TraceDate!
        newTrace["TSportAssocie"] = TraceSport!
        newTrace["TImage"] = CKAsset(fileURL: tmpImageTraceUrl!)
        newTrace["TEquipementsAssocie"] = TraceEquipements!
        
     
        database.save(newTrace, completionHandler: { (record:CKRecord?, error:Error?) -> Void in
            if error != nil{
                print("Record OK \(record)")
            }
        })
        
        
    
    }
    

}
