//
//  ViewControllerHome.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 27/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit


class ViewControllerHome: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    
        
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "iPhone7Back.png")
        self.view.insertSubview(backgroundImage, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
