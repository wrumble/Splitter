//
//  BillImageViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 15/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class BillReceiptViewController: UIViewController {
    
    var billObject: NSManagedObject!
    var bill: Bill!
    
    @IBOutlet var receiptImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        do {
            let results =
                try managedContext.existingObjectWithID(billObject.objectID)
            bill = results as! Bill
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        receiptImageView.image = appDelegate.imageStore.imageForKey(bill.id!)
        
        self.navigationItem.title = "\(bill.name!) receipt image"

    }
    
}
