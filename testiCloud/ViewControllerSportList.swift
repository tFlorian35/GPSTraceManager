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

    
    @IBOutlet weak var tableViewSport: UITableView!
    
    
    
    
    var TabSport = ["Foot","Kite","Tennis"]
    var DBTabSports = [SportClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableViewSport.delegate = self
        tableViewSport.dataSource = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableViewSport.indexPathForSelectedRow {
            tableViewSport.deselectRow(at: indexPath, animated: true)
        }
        
        loadSports()
    }
    
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
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of whistles; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(op)
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.DBTabSports.count
    }
    
    /*func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }*/
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewSport.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCellSportList
        //cell.accessoryType = .disclosureIndicator

        cell.SportName.text = DBTabSports[indexPath.row].SDesiniation
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") {action, index in
            print("Delete pressed")
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Partager") {action, index in
            print("Partager cliqué")
        }
        
        
        
        return [delete, share]
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @IBAction func addSport(_ sender: Any) {
      
    }
    
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewSport.dequeueReusableCell(withIdentifier: "cell", for:indexPath) as! TableViewCellSportList
        
        cell.SportName.text = TabSport[indexPath.row]
        return cell
    }*/
    
    
}
