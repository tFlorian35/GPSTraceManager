//
//  TableViewCellSportList.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 09/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit

class TableViewCellSportList: UITableViewCell {

    @IBOutlet weak var SportName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
