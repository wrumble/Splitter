//
//  NewBillViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 27/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class NewBillViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imageStore = ImageStore()
    var newBill: Bill = Bill()
        
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
        imageStore.setImage(image, forKey: newBill.billID)
        imageView!.image = image
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func assignDate() -> String {
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .NoStyle
        formatter.dateStyle = .LongStyle
        
        return formatter.stringFromDate(currentDateTime)
    }
    
    @IBAction func saveButtonWasPressed() {
        //newBill.image =
        newBill.name = billName?.text
        newBill.date = assignDate()
        newBill.location = billLocation?.text
        
        self.performSegueWithIdentifier("segueToMyBills", sender: self)
        
        newBill.setBillImage()
    }
}
