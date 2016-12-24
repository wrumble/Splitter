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

class NewBillViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, WDImagePickerDelegate {
    
    var newBill: NSManagedObject?
    var itemConverter = TextToItemConverter()
    var imagePicker: WDImagePicker!
    var popoverController: UIPopoverController!
    var imagePickerController: UIImagePickerController!
    
    @IBOutlet var billName: UITextField?
    @IBOutlet var billLocation: UITextField?
    @IBOutlet var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Splitter"
        self.navigationItem.hidesBackButton = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewBillViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func performImageRecognition(image: UIImage) {
        let tesseract = G8Tesseract(language: "eng")
        var textFromImage: String?
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .SingleBlock
        tesseract.maximumRecognitionTime = 10.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        textFromImage = tesseract.recognizedText
        itemConverter.seperateTextToLines(textFromImage!)
    }
    
    @IBAction func saveButtonWasPressed() {
        
        let image = imageView!.image!
        let id = NSUUID().UUIDString
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Bill", inManagedObjectContext: managedContext)
        let newBill = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
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
        self.performSegueWithIdentifier("segueToMyBills", sender: self)
    }
    
    @IBAction func takeBillPicture(button: UIButton) {
        self.imagePicker = WDImagePicker()
        self.imagePicker.cropSize = CGSizeMake(280, 280)
        self.imagePicker.delegate = self
        self.imagePicker.resizableCropArea = true
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.popoverController = UIPopoverController(contentViewController: self.imagePicker.imagePickerController)
            self.popoverController.presentPopoverFromRect(button.frame, inView: self.view, permittedArrowDirections: .Any, animated: true)
        } else {
            self.presentViewController(self.imagePicker.imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePicker(imagePicker: WDImagePicker, pickedImage: UIImage) {
        self.imageView!.image = pickedImage
        self.hideImagePicker()
    }
    
    func hideImagePicker() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.popoverController.dismissPopoverAnimated(true)
        } else {
            self.imagePicker.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.imageView!.image = image
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.popoverController.dismissPopoverAnimated(true)
        } else {
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
