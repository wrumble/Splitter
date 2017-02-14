//
//  NewBillSplitterViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 19/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class NewBillSplitterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bill: NSManagedObject!
    var billName: String!
    var allItems: [Item]!
    var selectedItems = [Item]()
    var checked = [Bool]()
    var profileImage = UIImageView()
    var session: AVCaptureSession?
    var splitter: BillSplitter?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    @IBOutlet var billSplitterName: UITextField!
    @IBOutlet var billSplitterEmail: UITextField!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchBillItems()
        
        if let splitter = splitter {
            for index in 0...(allItems!.count - 1) {
                let item = allItems?[index]
                if (splitter.items?.contains(item!))! {
                    checked.append(true)
                    selectedItems.append(item!)
                } else {
                    checked.append(false)
                }
            }
            billSplitterName.text = "\(splitter.name!)"
            billSplitterEmail.text = "\(splitter.email!)"
        } else {
            for _ in 0...allItems.count {
                checked.append(false)
                if Platform.isPhone {
                    billSplitterName?.addTarget(self, action: #selector(capturePhoto), for: .editingDidEnd)
                }
            }
        }
        
        tableView.allowsMultipleSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewBillSplitterViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if splitter == nil && Platform.isPhone {
            session = AVCaptureSession()
            session!.sessionPreset = AVCaptureSessionPresetPhoto
            
            var frontCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            for device in availableCameraDevices as! [AVCaptureDevice] {
                if device.position == .front {
                    frontCamera = device
                }
            }
            
            var error: NSError?
            var input: AVCaptureDeviceInput!
            do {
                input = try AVCaptureDeviceInput(device: frontCamera)
            } catch let error1 as NSError {
                error = error1
                input = nil
                print(error!.localizedDescription)
            }
            
            if error == nil && session!.canAddInput(input) {
                session!.addInput(input)
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                
                if session!.canAddOutput(stillImageOutput) {
                    session!.addOutput(stillImageOutput)
                    session!.startRunning()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! BillSplittersViewController
        let passedBill: NSManagedObject = bill as NSManagedObject

        destinationVC.allBillSplitters = getUpdatedSplitters()
        destinationVC.billName = billName
        destinationVC.bill = passedBill
    }
    
    func getUpdatedSplitters() -> [BillSplitter] {
        var allBillSplitters = [BillSplitter]()
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BillSplitter")
        let predicate = NSPredicate(format: "ANY bills == %@", bill)
        
        fetchRequest.predicate = predicate
        
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            allBillSplitters = results as! [BillSplitter]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return allBillSplitters
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        fetchBillItems()
        
        let cell: BillSplitterItemCell = tableView.dequeueReusableCell(withIdentifier: "billSplitterItemCell", for: indexPath) as! BillSplitterItemCell
        let item = allItems?[indexPath.row]
        let numberOfSplitters = item?.billSplitters?.count
        var sharedSplittersText = String()
        
        if numberOfSplitters == 0 {
            sharedSplittersText = "No one is paying for this item yet."
        } else {
            
            sharedSplittersText = "Split with "
            let itemSplitters = item?.billSplitters?.allObjects as! [BillSplitter]
            for i in 0...Int((numberOfSplitters)!-1) {
                if numberOfSplitters == 1 {
                    sharedSplittersText += "\(itemSplitters[i].name!)"
                } else {
                    sharedSplittersText += ", \(itemSplitters[i].name!)"
                }
            }
        }
        
        cell.name.text = "\(item!.name!)\n\(sharedSplittersText)"
        cell.price.text = "\(item!.price.asLocalCurrency)"
        cell.tintColor = .black
        
        if !checked[indexPath.row] {
            cell.accessoryType = .none
        } else if checked[indexPath.row] {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                selectedItems.remove(at: selectedItems.index(of: allItems[indexPath.row])!)
                checked[indexPath.row] = false
            } else {
                cell.accessoryType = .checkmark
                selectedItems.append((allItems?[indexPath.row])!)
                checked[indexPath.row] = true
            }
        }
    }
    
    func fetchBillItems() {
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "bill == %@", bill)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            allItems = results as! [Item]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonWasPressed() {
        
        DispatchQueue.global(qos: .background).async { [weak weakSelf = self] in
            
            let managedContext = weakSelf?.bill.managedObjectContext
            let notificationCenter = NotificationCenter.default

            notificationCenter.addObserver(self, selector: #selector(weakSelf?.managedContextDidSave), name: NSNotification.Name.NSManagedObjectContextDidSave, object: managedContext)
            
            if let splitter = weakSelf?.splitter {
                splitter.mutableSetValue(forKey: "items").removeAllObjects()
                weakSelf?.setBillSplitterValues(splitter)
                weakSelf?.setSelectedItemsToBillSplitter(splitter)
            } else {
                let entity =  NSEntityDescription.entity(forEntityName: "BillSplitter", in: managedContext!)
                let newBillSplitter = NSManagedObject(entity: entity!, insertInto: managedContext)
                
                weakSelf?.setBillSplitterValues(newBillSplitter)
                weakSelf?.setSelectedItemsToBillSplitter(newBillSplitter)
            }
            
            do {
                try managedContext!.save()
            }
            catch let error as NSError {
                print("Core Data save failed: \(error)")
            }
            
        }
        
    }
    
    func managedContextDidSave() {
        DispatchQueue.main.async { [weak weakSelf = self] in
            guard let weakSelf = weakSelf else { return }
            weakSelf.performSegue(withIdentifier: "segueToBillSplitters", sender: self)
        }
    }
    
    func setSelectedItemsToBillSplitter(_ splitterObject: NSManagedObject) {
        
        selectedItems.forEach { item in
            let splitterItems = splitterObject.mutableSetValue(forKey: "items")
            splitterItems.add(item)
        }
    }
        
    func setBillSplitterValues(_ splitterObject: NSManagedObject) {
        
        splitterObject.setValue(billSplitterName?.text?.trim(), forKey: "name")
        splitterObject.setValue(billSplitterEmail?.text?.trim(), forKey: "email")
        
        if splitter == nil {
            let currentBillSplitters = self.bill.mutableSetValue(forKey: "billSplitters")
            if Platform.isPhone {
                let imageData = UIImageJPEGRepresentation(profileImage.image!, 1)
                splitterObject.setValue(imageData, forKey: "image")
            }
            currentBillSplitters.add(splitterObject)
        }
        }
    
    func capturePhoto() {
        DispatchQueue.global(qos: .background).async { [weak weakSelf = self] in
            if let videoConnection = weakSelf?.stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
                weakSelf?.stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                    if sampleBuffer != nil {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        let dataProvider = CGDataProvider(data: imageData as! CFData)
                        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                        weakSelf?.profileImage.image = image
                    }
                })
            }
        }
    }
}
