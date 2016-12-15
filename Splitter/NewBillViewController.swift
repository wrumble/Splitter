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

class NewBillViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var newBill: NSManagedObject?
    var itemConverter = TextToItemConverter()
    var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet var myBillsButton: UIButton!
    @IBOutlet var billName: UITextField?
    @IBOutlet var billLocation: UITextField?
    @IBOutlet var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Splitter"
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewBillViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView!.image = image
        
        view.setNeedsDisplay()
        dismissViewControllerAnimated(true, completion: nil)
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
    
    @IBAction func myBillsButonWasPressed() {
        self.performSegueWithIdentifier("segueToMyBills", sender: self)
    }
    
    @IBAction func takeBillPicture(sender: UIBarButtonItem) {
        
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
        } else {
            imagePicker.sourceType = .PhotoLibrary
        }
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
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
        
        self.performSegueWithIdentifier("segueToMyBills", sender: self)
        self.performImageRecognition(image)
    }
}
