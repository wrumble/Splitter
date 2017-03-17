//
//  NewBillViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 27/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import WDImagePicker
import NVActivityIndicatorView

class NewBillViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, WDImagePickerDelegate, NVActivityIndicatorViewable {
    
    var imagePickerController: UIImagePickerController!
    var textFromImage: String!
    var itemConverter = TextToItemConverter()
    var imagePicker = WDImagePicker()
    var places = Places()
    var instructionLabel = NewBillInstructionLabel()
    
    @IBOutlet weak var billName: UITextField!
    @IBOutlet weak var billLocation: UITextField?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        addGestureRecognisers()
        addInstructionLabel()
        addTextFieldTargets()
    }
    
//MARK: view did load functions
//AddsGesturerecognisers to textfields n shit
    func addGestureRecognisers() {
        
        let nameTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(nameTap)
        
        let locationTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(locationFieldWasTapped))
        billLocation?.addGestureRecognizer(locationTap)
    }
    
//Hides keyboard when tapping anywhere other than a textfield.
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
//Assign target functions to any textFields that need them.
    func addTextFieldTargets() {
        billLocation!.addTarget(self, action: #selector(NewBillViewController.locationFieldWasTapped(_:)), for: UIControlEvents.touchDown)
    }
    
//Adds text explaing how to take an effective photo of your receipt.
    func addInstructionLabel() {
        
        imageView?.addSubview(instructionLabel)
    }
    
//MARK: Location textField functions
//If a nearest place was found create the alert displaying it.
    func locationFieldWasTapped(_ textField: UITextField) {
        
        if places.nearestBarCafeRestaurant != nil {
            
            createAlert(textField)
        }
    }
    
//Create Alert View
    func createAlert(_ textField: UITextField) {
        
        let alert = UIAlertController(title: "Are you here?", message: places.nearestBarCafeRestaurant!, preferredStyle: UIAlertControllerStyle.alert)
        addNoAction(alert, textField: textField)
        addOkAction(alert, textField: textField)
        
        self.present(alert, animated: true, completion: nil)
    }
    
//No action sets keyboard on location textfield.
    func addNoAction(_ alert: UIAlertController, textField: UITextField) {
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
            textField.becomeFirstResponder()
        }))
    }
    
//Ok action inserts suggested place name and hides keyboard
    func addOkAction(_ alert: UIAlertController, textField: UITextField) {
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.fillInTextField(textField)
            self.resignResponders()
            self.dismissKeyboard()
        }))
    }
    
//Fills in textfield with place name
    func fillInTextField(_ textField: UITextField) {
        
        textField.text = places.nearestBarCafeRestaurant!
    }
    
//Resign text field responders
    func resignResponders() {
        
        self.billName?.resignFirstResponder()
        self.billLocation?.resignFirstResponder()
    }
    
//MARK: Receipt capturing functions
//Prepare and present Image picker for taking receipt picture
    @IBAction func takeBillPicture(_ button: UIButton) {
        
        setImagePicker()
        present(self.imagePicker.imagePickerController, animated: true, completion: nil)
    }
    
//Set image picker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        picker.cameraFlashMode = .auto
        picker.dismiss(animated: true, completion: nil)
    }
    
//Set Image picker
    func setImagePicker() {
        
        imagePicker.cropSize = CGSize(width: 280, height: 280)
        imagePicker.delegate = self
        imagePicker.resizableCropArea = true
    }
    
//Delegates what to do after user has taken a photo
    func imagePicker(_ imagePicker: WDImagePicker, pickedImage: UIImage) {
        
        saveImage(pickedImage)
        hideInstructionLabel()
        hideImagePicker()
    }
    
//Saves image while fixing it orientation.
    func saveImage(_ pickedImage: UIImage) {
        
        imageView!.image = pickedImage.fixOrientation()
    }
    
//Removes initial instruction value from view
    func hideInstructionLabel() {
        
        instructionLabel.removeFromSuperview()
    }
    
//Hides the image picker
    func hideImagePicker() {
        
        imagePicker.imagePickerController.dismiss(animated: true, completion: nil)
    }
    
//MARK: Saving the new bill functions
//Save New bill data and recognise the text from the image
    @IBAction func saveButtonWasPressed() {
        
        if imageView.image != nil {
            
            processBillData()
        }
    }
    
//Begin process of saving bill to coredata
    func processBillData() {
        
        startAnimating()
        processImage()
        saveBill()
        setThreadQueues()
    }
    
//Saves bill data to coreData
    func saveBill() {
        
        let bill = CoreDataHelper().saveBill(setBillValues())
        self.itemConverter.bill = bill
    }
    
//Preprocesses the image to optimise use with tesseract
    func processImage() {
        
        imageView.image! = imageView.image!.toGrayScale()
        imageView.image! = imageView.image!.binarise()
        imageView.image! = imageView.image!.scaleImage()
    }
    
//Return values hash ready for bill to be saved to coredata
    func setBillValues() -> [String: Any] {
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)
        
        return ["name": (self.billName?.text?.trim())!,
                "location": (self.billLocation?.text?.trim())!,
                "image": imageData!] as [String: Any]
    }
    
//Set high work load image recognition to background thread.
    func setThreadQueues() {
        
        DispatchQueue.global(qos: .background).async { [weak weakSelf = self] in
            
            weakSelf?.performImageRecognition()
            weakSelf?.convertImageText()
            weakSelf?.setMainQueueThread()
        }
    }
    
//Recognise image text using tesseract
    func performImageRecognition() {
        
        textFromImage = Tesseract().recognise(imageView.image!)
    }
    
//Convert image text to Bill Items
    func convertImageText() {
        
        itemConverter.seperateTextToLines(textFromImage)
    }
    
//Set main queue thread
    func setMainQueueThread() {
        
        DispatchQueue.main.async {
            
            self.stopAnimating()
            self.performSegue(withIdentifier: "segueToBills", sender: self)
        }
    }
}
