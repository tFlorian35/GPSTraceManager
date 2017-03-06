//
//  TableViewCellEquipementList.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 16/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit

class TableViewCellEquipementList: UITableViewCell {
    
    @IBOutlet weak var designation: UILabel!
    
    @IBOutlet weak var dateachat: UILabel!

    @IBOutlet weak var equipementImage: UIImageView!
    
    @IBOutlet weak var etatLabel: UILabel!
   
    @IBOutlet weak var commentaire: UILabel!
    
    @IBOutlet weak var nbutilisations: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
