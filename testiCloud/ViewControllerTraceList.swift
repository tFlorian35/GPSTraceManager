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
        
    
        
        if(traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: view)
            print("3DTOUCH AVAILABLE")
        }else{
            print("3DTOUCH is not available")
        
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
        op.desiredKeys = ["TTitre", "TImage", "TDate", "TSportAssocie", "TEquipementsAssocie" ]
        
        var newTrace = [TraceClass]()
        
        op.recordFetchedBlock = {record in
            let lesTraces = TraceClass()
            lesTraces.recordID = record.recordID
            
            lesTraces.TTitre = record["TTitre"] as! String!
            lesTraces.TSport = record["TSport"] as! String!
            lesTraces.TDate = record["TDate"] as! String!
            lesTraces.TEquipementsAssocie = record["TEquipementsAssocie"] as! [String]!
            
            if let photoAsset = record.value(forKey: "TImage") as? CKAsset{
                lesTraces.TImage = UIImage(data: NSData(contentsOf: photoAsset.fileURL)! as Data)
            }
            
            
            
            newTrace.append(lesTraces)
            
            print(newTrace)
            
            
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
        CellT.dateTrace.text = DBTabTrace[indexPath.row].TDate
        CellT.sportTrace.text = DBTabTrace[indexPath.row].TSport
        
        
        
        
        var i:String = ""
        if DBTabTrace[indexPath.row].TEquipementsAssocie != nil{
            for element in DBTabTrace[indexPath.row].TEquipementsAssocie{
                i += "\(element) \n"
                
                CellT.tvEqpts.text = i
            }
            
        }else{
            CellT.tvEqpts.text = "Vous n'avez pas associé d'équipements à cette trace"
        }
        
        
        
        //Design
        CellT.selectionStyle = .none
        
        CellT.contentView.backgroundColor = UIColor.clear
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 201))
        
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        CellT.contentView.addSubview(whiteRoundedView)
        CellT.contentView.sendSubview(toBack: whiteRoundedView)
        
        
        
        
        
        return CellT
    }
    
    
    //Action when slide on the cell
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") {action, index in
            let database = CKContainer.default().publicCloudDatabase
    
            
            
            
            
            print("Delete pressed")
            let recName = self.DBTabTrace[indexPath.row].TTitre!
            print(recName)
            database.delete(withRecordID: CKRecordID(recordName: recName), completionHandler: {recordID, error in
                NSLog("OK or \(error)")
                
                if error == nil {
                    print("NoError")
                    self.tableViewTraces.reloadData()
                }
            })
            
            
    
    
        }

        
        return [delete]
        
    }
    
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
