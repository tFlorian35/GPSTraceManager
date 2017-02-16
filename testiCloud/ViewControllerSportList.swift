//
//  ViewControllerSportList.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 09/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit
import CloudKit


class ViewControllerSportList: ViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var reloadButton: UIToolbar!
    @IBOutlet weak var isReloadingLoader: UIActivityIndicatorView!
    @IBOutlet weak var tableViewSport: UITableView!
    var tField: UITextField!
    
    
    var TabSport = ["Foot","Kite","Tennis"]
    var DBTabSports = [SportClass]()
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableViewSport.delegate = self
        tableViewSport.dataSource = self
        
        loadSports()
        
        refreshControl.addTarget(self, action: #selector(ViewControllerSportList.refreshData), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *){
            tableViewSport.refreshControl = refreshControl
        }else{
            tableViewSport.addSubview(refreshControl)
        }
        
    }
    
    func refreshData(){
        print("refreshing")
        self.viewDidLoad()
        self.viewWillAppear(true)
        refreshControl.endRefreshing()
    }
    
    
    //Load the sport from the database
    func loadSports(){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Sport", predicate: predicate)
        
        let op = CKQueryOperation(query: query)
        op.desiredKeys = ["SDesiniation"]
        var newSports = [SportClass]()
        
        op.recordFetchedBlock = {record in
            let lesSports = SportClass()
            lesSports.recordID = record.recordID
            lesSports.SDesiniation = record["SDesiniation"] as! String!
    
            newSports.append(lesSports)
    
    
        }
        
        op.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    //ViewController.isDirty = false
                    self.DBTabSports = newSports
                    self.tableViewSport.reloadData()
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
        return self.DBTabSports.count
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewSport.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCellSportList
        //cell.accessoryType = .disclosureIndicator
        cell.SportName.text = DBTabSports[indexPath.row].SDesiniation
        return cell
    }
    
    //Action when slide on the cell
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") {action, index in
            let database = CKContainer.default().publicCloudDatabase
            
            
            print("Delete pressed")
            let recName = self.DBTabSports[indexPath.row].SDesiniation
            print(recName)
            database.delete(withRecordID: CKRecordID(recordName: recName!), completionHandler: {recordID, error in
                NSLog("OK or \(error)")
            })
            self.isReloadingLoader.startAnimating()
            self.viewDidLoad()
            self.viewWillAppear(true)
            self.isReloadingLoader.stopAnimating()
        }
        
        return [delete]
        
    }
    
    //Add nex sport into db
    @IBAction func addSport(_ sender: Any) {
        
        
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
       
    }
    
    
    @IBAction func reloadClicked(_ sender: Any) {
        self.isReloadingLoader.startAnimating()
        self.viewDidLoad()
        self.viewWillAppear(true)
        self.isReloadingLoader.stopAnimating()
    }
    
    
}
