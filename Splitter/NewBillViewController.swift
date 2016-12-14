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
    
    var imageStore = ImageStore()
    var newBill: NSManagedObject?
    var itemConverter = TextToItemConverter()
    var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet var myBillsButton: UIButton!
    @IBOutlet var billName: UITextField?
    @IBOutlet var billLocation: UITextField?
    @IBOutlet var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewBillViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

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
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    func performImageRecognition(image: UIImage) {
        let tesseract = G8Tesseract(language: "eng")
        var textFromImage: String?
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .SingleBlock
        tesseract.maximumRecognitionTime = 10.0
        tesseract.image = image.g8_blackAndWhite()
        addActivityIndicator()
        tesseract.recognize()
        textFromImage = tesseract.recognizedText
        itemConverter.seperateTextToLines(textFromImage!)
        removeActivityIndicator()
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
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        imageStore.setImage(image, forKey: id)
        itemConverter.billObject = managedContext.objectWithID(newBill.objectID)
        
        self.performImageRecognition(image)
        self.performSegueWithIdentifier("segueToMyBills", sender: self)
    }
}
