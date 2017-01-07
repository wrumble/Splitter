//
//  NewBillViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 27/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import TesseractOCR
import CoreData
import WDImagePicker
import GooglePlaces
import CoreLocation

class NewBillViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, WDImagePickerDelegate {
    
    let locationManager = CLLocationManager()
    
    var newBill: NSManagedObject?
    var itemConverter = TextToItemConverter()
    var imagePicker: WDImagePicker!
    var popoverController: UIPopoverController!
    var imagePickerController: UIImagePickerController!
    var placesClient = GMSPlacesClient()
    var nearestPlaceName = String()
    
    @IBOutlet var billName: UITextField?
    @IBOutlet var billLocation: UITextField?
    @IBOutlet var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        getNearestPlaceName()
        
        self.navigationItem.title = "Splitter"
        self.navigationItem.hidesBackButton = true
        
        
        billLocation!.addTarget(self, action: #selector(NewBillViewController.locationFieldWasTapped(_:)), for: UIControlEvents.touchDown)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewBillViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.black
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func performImageRecognition(_ image: UIImage) {
        let tesseract = G8Tesseract(language: "eng")
        var textFromImage: String?
        tesseract?.engineMode = .tesseractCubeCombined
        tesseract?.pageSegmentationMode = .singleBlock
        tesseract?.maximumRecognitionTime = 10.0
        tesseract?.image = image.g8_blackAndWhite()
        tesseract?.recognize()
        textFromImage = tesseract?.recognizedText
        itemConverter.seperateTextToLines(textFromImage!)
    }
    
    @IBAction func saveButtonWasPressed() {
        
        let image = imageView!.image!
        let id = UUID().uuidString
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Bill", in: managedContext)
        let newBill = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        newBill.setValue(billName?.text, forKey: "name")
        newBill.setValue(billLocation?.text, forKey: "location")
        newBill.setValue(id, forKey: "id")
        
        appDelegate.imageStore.setImage(image, forKey: id)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        let bill: NSManagedObject = newBill as NSManagedObject
        itemConverter.bill = bill
        
        self.performImageRecognition(image)
        self.performSegue(withIdentifier: "segueToMyBills", sender: self)
    }
    
    @IBAction func takeBillPicture(_ button: UIButton) {
        self.imagePicker = WDImagePicker()
        self.imagePicker.cropSize = CGSize(width: 280, height: 280)
        self.imagePicker.delegate = self
        self.imagePicker.resizableCropArea = true
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.popoverController = UIPopoverController(contentViewController: self.imagePicker.imagePickerController)
            self.popoverController.present(from: button.frame, in: self.view, permittedArrowDirections: .any, animated: true)
        } else {
            self.present(self.imagePicker.imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePicker(_ imagePicker: WDImagePicker, pickedImage: UIImage) {
        self.imageView!.image = pickedImage
        self.hideImagePicker()
    }
    
    func hideImagePicker() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.popoverController.dismiss(animated: true)
        } else {
            self.imagePicker.imagePickerController.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        self.imageView!.image = image
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.popoverController.dismiss(animated: true)
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func locationFieldWasTapped(_ textField: UITextField) {
        let alert = UIAlertController(title: "Are you here?", message: nearestPlaceName, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.dismissKeyboard()
            textField.text = self.nearestPlaceName
        }))
        
        let subview = alert.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        alertContentView.backgroundColor = UIColor.darkGray
        alertContentView.layer.cornerRadius = 13
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.black;
    }
    
    func getNearestPlaceName() {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                var places = placeLikelihoodList.likelihoods.filter() {
                    if let type = ($0 as GMSPlaceLikelihood).place.types as [String]! {
                        return type.contains("bar") || type.contains("restaurant") || type.contains("cafe")
                    } else {
                        return false
                    }
                }
                
                places.sort {$0.likelihood > $1.likelihood}
                self.nearestPlaceName = places[0].place.name
            }
        })
    }
}
