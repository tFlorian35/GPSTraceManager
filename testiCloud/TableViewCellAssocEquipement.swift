//
//  TableViewCellAssocEquipement.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 27/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit

class TableViewCellAssocEquipement: UITableViewCell{

    
    @IBOutlet weak var eqptName: UILabel!
    @IBOutlet weak var eqptImage: UIImageView!
    @IBOutlet weak var checkMark: UILabel!
    
    
    var returnValueAdd:String = ""
    var returnValueMinus:String = ""
    var tabEqptsAssocies = [String]()
    
    
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

}
