//
//  ViewControllerEquipementList.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 16/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit
import CloudKit

class ViewControllerEquipementsList: ViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableViewEquipements: UITableView!
    var tField: UITextField!
    var DBTabEquipements = [EquipementsClass]()
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableViewEquipements.delegate = self
        tableViewEquipements.dataSource = self
        
        loadEquipements()
        
        refreshControl.addTarget(self, action: #selector(ViewControllerSportList.refreshData), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *){
            tableViewEquipements.refreshControl = refreshControl
        }else{
            tableViewEquipements.addSubview(refreshControl)
        }
        
    }
    
    func refreshData(){
        print("refreshing")
        self.viewDidLoad()
        self.viewWillAppear(true)
        refreshControl.endRefreshing()
    }
    
    
    //Load the equipements from the database
    func loadEquipements(){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Equipement", predicate: predicate)
        
        let op = CKQueryOperation(query: query)
        op.desiredKeys = ["Ecommentaire"]
        op.desiredKeys = ["EdateAchat"]
        op.desiredKeys = ["Edesignation"]
        op.desiredKeys = ["Eetat"]
        op.desiredKeys = ["Eimage"]
        var newEquipement = [EquipementsClass]()
        
        op.recordFetchedBlock = {record in
            let lesEquipements = EquipementsClass()
            lesEquipements.recordID = record.recordID
            
            lesEquipements.Ecommentaire = record["Ecommentaire"] as! String!
            //lesEquipements.EdateAchat = record["EdateAchat"] as! Date!
            lesEquipements.Edesignation = record["Edesignation"] as! String!
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
                    self.tableViewEquipements.reloadData()
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
        return self.DBTabEquipements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellE = tableViewEquipements.dequeueReusableCell(withIdentifier: "cellE", for: indexPath) as! TableViewCellEquipementList
        cellE.accessoryType = .disclosureIndicator
        
        cellE.designation.text = DBTabEquipements[indexPath.row].Edesignation
        cellE.etatLabel.text = DBTabEquipements[indexPath.row].Eetat
        cellE.commentaire.text = DBTabEquipements[indexPath.row].Ecommentaire
        //cellE.dateachat.text = DBTabEquipements[indexPath.row].EdateAchat
        cellE.equipementImage.image = DBTabEquipements[indexPath.row].Eimage
        
        return cellE
    }
    
    //Action when slide on the cell
    /*func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") {action, index in
            let database = CKContainer.default().publicCloudDatabase
            
            print("Delete pressed")
            let recName = self.DBTabEquipements[indexPath.row].Edesignation
            print(recName)
            database.delete(withRecordID: CKRecordID(recordName: recName!), completionHandler: {recordID, error in
                NSLog("OK or \(error)")
            })
        }
        
        return [delete]
        
    }*/
    
    //Add nex sport into db
    /*@IBAction func addSport(_ sender: Any) {
        
        
        func configurationTextField(textField: UITextField!)
        {
            print("generating the TextField")
            textField.placeholder = "Entrez votre sport"
            tField = textField
        }
        
        func handleCancel(alertView: UIAlertAction!)
        {
            print("Annulé !!")
        }
        
        let alert = UIAlertController(title: "Nouveau sport", message: "", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ajouter", style: .default, handler:{ (UIAlertAction) in
            print("Ajout réussie !!")
            print("Item : \(self.tField.text!)")
            
            //Begin DB Stuff
            //let uniqueId = arc4random_uniform(99999)
            let database = CKContainer.default().publicCloudDatabase
            let SportName = self.tField.text as! CKRecordValue
            let SportRecordID = CKRecordID(recordName: "\(SportName)")
            let newTrace = CKRecord(recordType: "Sport", recordID: SportRecordID)
            
            newTrace["SDesiniation"] = SportName
            
            database.save(newTrace, completionHandler: { (record:CKRecord?, error:Error?) -> Void in
                if error != nil{
                    print("Record OK \(record)")
                }
            })
            
            //End DB Stuff
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }*/
    
}
