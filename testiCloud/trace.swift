//
//  trace.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 20/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//


import Foundation

import CloudKit
import UIKit

class TraceClass: NSObject {
    var recordID : CKRecordID?
    var TTitre : String!
    var TTrace : [CLLocation]!
    var TImage : UIImage!
    
    var TDate : String!
    var TEquipementsAssocie:[String]!
    var TSport:String!
    
}
