//
//  NewBillViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 27/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import TesseractOCR

class NewBillViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imageStore = ImageStore()
    var newBill: Bill = Bill()
    var itemConverter = TextToItemConverter()
    var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var billName: UITextField?
    @IBOutlet var billLocation: UITextField?
    @IBOutlet var myBillsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewBillViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageStore.setImage(image, forKey: newBill.id)
        imageView!.image = image
        
        addActivityIndicator()
        
        dismissViewControllerAnimated(true, completion: {
            self.performImageRecognition(image)
        })
    }
    
    func assignDate() -> String {
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .NoStyle
        formatter.dateStyle = .LongStyle
        
        return formatter.stringFromDate(currentDateTime)
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
        tesseract.recognize()
        textFromImage = tesseract.recognizedText
        itemConverter.itemBillID = newBill.id
        itemConverter.seperateTextToLines(textFromImage!)
        removeActivityIndicator()
    }
    
    @IBAction func saveButtonWasPressed() {
        newBill.name = billName?.text
        newBill.date = assignDate()
        newBill.location = billLocation?.text
        addActivityIndicator()
        newBill.setBillImage()
        self.performSegueWithIdentifier("segueToMyBills", sender: self)
    }
}
