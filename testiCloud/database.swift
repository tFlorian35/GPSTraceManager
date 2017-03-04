//
//  database.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 03/03/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import CloudKit

var PRIVATEDB = CKContainer.default().privateCloudDatabase
var PUBLiCDB = CKContainer.default().publicCloudDatabase
var SHAREDB = CKContainer.default().sharedCloudDatabase


