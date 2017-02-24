//
//  ViewControllerTraceList.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 20/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit
import CloudKit
class ViewControllerTraceList: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewTraces: UITableView!
    var DBTabTrace = [TraceClass]()
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewTraces.delegate = self
        tableViewTraces.dataSource = self

        loadTraces()
        
        refreshControl.addTarget(self, action: #selector(ViewControllerTraceList.refreshData), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *){
            tableViewTraces.refreshControl = refreshControl
        }else{
            tableViewTraces.addSubview(refreshControl)
        }
    
    }
    
    func refreshData(){
        print("refreshing")
        loadTraces()
        self.viewDidLoad()
        self.viewWillAppear(true)
        refreshControl.endRefreshing()
    }
    
    func loadTraces(){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Trace", predicate: predicate)
        
        let op = CKQueryOperation(query: query)
        op.desiredKeys = ["TTitre", "TImage"]
        var newTrace = [TraceClass]()
        
        op.recordFetchedBlock = {record in
            let lesTraces = TraceClass()
            lesTraces.recordID = record.recordID
            
            lesTraces.TTitre = record["TTitre"] as! String!
            
            if let photoAsset = record.value(forKey: "TImage") as? CKAsset{
                lesTraces.TImage = UIImage(data: NSData(contentsOf: photoAsset.fileURL)! as Data)
            }
            
            
            
            newTrace.append(lesTraces)
            
            
        }
        
        op.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    //ViewController.isDirty = false
                    self.DBTabTrace = newTrace
                    self.tableViewTraces.reloadData()
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
        return self.DBTabTrace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellT = tableViewTraces.dequeueReusableCell(withIdentifier: "CellT", for: indexPath) as! TableViewCellTraceList
        //cellE.accessoryType = .disclosureIndicator
        
        CellT.imageTrace.image = DBTabTrace[indexPath.row].TImage
        CellT.nomTrace.text = DBTabTrace[indexPath.row].TTitre
        
        
        return CellT
    }
    
    //Action when slide on the cell
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") {action, index in
            func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                return 0.0
            }
            let database = CKContainer.default().publicCloudDatabase
            
            print("Delete pressed")
            let recName = self.DBTabTrace[indexPath.row].TTitre
            print(recName)
            database.delete(withRecordID: CKRecordID(recordName: recName!), completionHandler: {recordID, error in
                NSLog("OK or \(error)")
            })
            
            
            
        }
        
        return [delete]
        
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
