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
import NVActivityIndicatorView

class NewBillViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, WDImagePickerDelegate, NVActivityIndicatorViewable {
    
    var newBill: NSManagedObject?
    var itemConverter = TextToItemConverter()
    var imagePicker: WDImagePicker!
    var imagePickerController: UIImagePickerController!
    var placesClient = GMSPlacesClient()
    var nearestPlaceName = String()
    var instructionLabel: UILabel!
    
    @IBOutlet weak var billName: UITextField!
    @IBOutlet weak var billLocation: UITextField?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        getNearestPlaceName()
        createInstructionLabel()
        
        billLocation!.addTarget(self, action: #selector(NewBillViewController.locationFieldWasTapped(_:)), for: UIControlEvents.touchDown)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewBillViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func createInstructionLabel() {
        let height = 200
        let width = Int(UIScreen.main.bounds.width)
        instructionLabel = UILabel(frame: CGRect(x:5, y:0, width: width - 5, height: height))
        instructionLabel.textColor = UIColor.black
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.text = "Once you have taken a clear, straight photo of your receipt. Crop the image so it contains only a list of each items name, price and quantity. You do not need to include the bill total in the cropped image."
        imageView?.addSubview(instructionLabel)
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
        
        if let image = imageView.image {
            startAnimating()
            let id = UUID().uuidString
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let entity =  NSEntityDescription.entity(forEntityName: "Bill", in: managedContext)
            let newBill = NSManagedObject(entity: entity!, insertInto: managedContext)
            let newBillSplittersArray = newBill.mutableSetValue(forKey: "billSplitters")
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            
            newBill.setValue(self.billName?.text, forKey: "name")
            newBill.setValue(self.billLocation?.text, forKey: "location")
            newBill.setValue(id, forKey: "id")
            newBill.setValue(imageData, forKey: "image")
            
            newBillSplittersArray.add(getMainBillSplitter())
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            let bill: NSManagedObject = newBill as NSManagedObject
            self.itemConverter.bill = bill
            
            DispatchQueue.global(qos: .background).async { [weak weakSelf = self] in
                
                weakSelf?.performImageRecognition(image)
                
                DispatchQueue.main.async {
                    
                    guard let weakSelf = weakSelf else { return }
                    weakSelf.stopAnimating()
                    weakSelf.performSegue(withIdentifier: "segueToBills", sender: weakSelf)
                }
            }
        } else {
            let alert = UIAlertController(title: "No receipt image", message: "You need to take a photo of your receipt before you can save the bill.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func takeBillPicture(_ button: UIButton) {
        self.imagePicker = WDImagePicker()
        self.imagePicker.cropSize = CGSize(width: 280, height: 280)
        self.imagePicker.delegate = self
        self.imagePicker.resizableCropArea = true

        self.present(self.imagePicker.imagePickerController, animated: true, completion: nil)
    }
    
    func imagePicker(_ imagePicker: WDImagePicker, pickedImage: UIImage) {
        self.instructionLabel.removeFromSuperview()
        self.imageView!.image = pickedImage
        self.hideImagePicker()
    }
    
    func hideImagePicker() {
        self.imagePicker.imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        self.imageView!.image = image
            
        picker.dismiss(animated: true, completion: nil)
    }
    
    func locationFieldWasTapped(_ textField: UITextField) {
        let alert = UIAlertController(title: "Are you here?", message: nearestPlaceName, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            textField.becomeFirstResponder()
        }))
            
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.billName?.resignFirstResponder()
            self.billLocation?.resignFirstResponder()
            self.dismissKeyboard()
            textField.text = self.nearestPlaceName
        }))

        self.present(alert, animated: true, completion: nil)
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
    
    func getMainBillSplitter() -> BillSplitter {
        
        var mainBillSplitter: BillSplitter!
        var allBillSplitters = [BillSplitter]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BillSplitter")
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            allBillSplitters = results as! [BillSplitter]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        allBillSplitters.forEach { billSplitter in
            if billSplitter.isMainBillSplitter {
                mainBillSplitter = billSplitter
            }
        }
        return mainBillSplitter
    }
}
