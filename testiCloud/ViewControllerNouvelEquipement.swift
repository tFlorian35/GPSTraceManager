//
//  ViewControllerNouvelEquipement.swift
//  GPSTraceManager
//
//  Created by Florian Tonnelier on 18/02/2017.
//  Copyright © 2017 Florian Tonnelier. All rights reserved.
//

import UIKit
import CloudKit
import Photos

class ViewControllerNouvelEquipement: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nomEquipement: UITextField!
    @IBOutlet weak var etatEquipement: UISegmentedControl!
    @IBOutlet weak var recupDate: UIDatePicker!
    @IBOutlet weak var commentaire: UITextField!
    @IBOutlet weak var selectedImage: UIImageView!
    
    //let picker = UIImagePickerController()
   
    let imagePicker =  UIImagePickerController()

    @IBAction func openCameraButton(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    //Saving Image here
    @IBAction func save(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(selectedImage.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    //Add image to Library
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Erreur d'enregistrement", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            
            let ac = UIAlertController(title: "Image enregistrée", message: "L'image attaché a l'équipement a bien été sauvegardée", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        selectedImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    
    
    
    @IBAction func EnregistreNouvelEquipement(_ sender: Any) {
        
        //DEC : Nom
        var ENom : String = nomEquipement.text!
        
        //DEC : Date
        let userDate = recupDate.datePickerMode = UIDatePickerMode.date
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        var EDate = dateFormatter.string(from: recupDate.date)
        
        //DEC : Etat equpt
        var EEtat : String = ""
        if(etatEquipement.selectedSegmentIndex == 0){
            EEtat = "Mauvais"
        }
        if(etatEquipement.selectedSegmentIndex == 1){
            EEtat = "Bon"
        }
        if(etatEquipement.selectedSegmentIndex == 2){
            EEtat = "Très bon"
        }
        
        //DEC : Commentaire
        let ECommentaire = commentaire.text!
    
        
        //DEC : Image
        let EImage = selectedImage.image!
        UIImageWriteToSavedPhotosAlbum(selectedImage.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    
        let tmpImage = UIImageJPEGRepresentation(EImage, 0.5)
        let imageUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
        do{
            try tmpImage!.write(to: imageUrl!)
            
        }catch let error as Error{
            print("error")
            return
        }
        
        //Save into Db
        //Begin DB Stuff
        let database = CKContainer.default().publicCloudDatabase
        
        
        let enom = ENom as CKRecordValue?
        let edate = EDate as CKRecordValue?
        let eetat = EEtat as CKRecordValue?
        let ecommentaire = ECommentaire as CKRecordValue?
        
        
        
        
        let EquipementRecordID = CKRecordID(recordName: "\(enom!)")
        let newEquipement = CKRecord(recordType: "Equipement", recordID: EquipementRecordID)
        
        newEquipement["Ecommentaire"] = ecommentaire
        newEquipement["EdateAchat"] = edate
        newEquipement["Edesignation"] = enom
        newEquipement["Eetat"] = eetat
        newEquipement["Eimage"] = CKAsset(fileURL:imageUrl!)
    
        
        database.save(newEquipement, completionHandler: { (record:CKRecord?, error:Error?) -> Void in
            if error != nil{
                print("Record OK")
            }
        })
        
        //End DB Stuff
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
