//
//  TableViewCellTraceList.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 23/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit

class TableViewCellTraceList: UITableViewCell {

    
    @IBOutlet weak var imageTrace: UIImageView!
    @IBOutlet weak var nomTrace: UILabel!
    @IBOutlet weak var sportTrace: UILabel!
    @IBOutlet weak var dateTrace: UILabel!
    @IBOutlet weak var tvEqpts: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
