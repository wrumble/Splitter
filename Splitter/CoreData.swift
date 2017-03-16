//
//  CoreDataHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 09/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
//Returns all the bills in coredata.
    func getAllBills() -> [Bill] {
        
        var allBills = [Bill]()
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            allBills = results as! [Bill]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        return allBills
    }
    
    func saveBill(_ values: [String: Any]) -> NSManagedObject {
        
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Bill", in: managedContext)
        let newBill = NSManagedObject(entity: entity!, insertInto: managedContext)
        let newBillSplittersArray = newBill.mutableSetValue(forKey: "billSplitters")
        
        newBill.setValue(values["name"], forKey: "name")
        newBill.setValue(values["location"], forKey: "location")
        newBill.setValue(values["image"], forKey: "image")
        
        newBillSplittersArray.add(returnMainBillSplitter())
        
        save(managedContext)
        
        return newBill
    }
    
    func returnMainBillSplitter() -> BillSplitter {
        
        var mainBillSplitter: BillSplitter!
        var allBillSplitters = [BillSplitter]()
        
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
    
//Saves any values passed as a bill splitter then saves that bill splitter to the bill passed.
    func saveBillSplitter(context: AnyObject, values: [String: Any]) {
        
        let managedContext = context.managedObjectContext!
        let entity =  NSEntityDescription.entity(forEntityName: "BillSplitter", in: managedContext)
        let billSplitter = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        if Platform.isPhone {

            let imageData = UIImageJPEGRepresentation(values["image"] as! UIImage, 0.5)
            billSplitter.setValue(imageData, forKey: "image")
        }
        
        values.forEach { value in

            if value.key != "image" {
                
                billSplitter.setValue(value.value, forKey: value.key)
            }
        }
        
        save(managedContext)
    }
    
//Deletes the bill and its related items, then deletes all related bill splitters but the main bill splitter.
    func deleteBill(bill: Bill) {
        
        let managedContext = appDelegate.managedObjectContext
        
        managedContext.delete(bill)
        
        bill.billSplitters?.forEach { splitter in
            
            if !(splitter as! BillSplitter).isMainBillSplitter  {
                
                managedContext.delete(splitter as! NSManagedObject)
            }
        }
        
        save(managedContext)
    }
    
//Saves whatever managed context is passed to it.
    func save(_ managedContext: NSManagedObjectContext) {
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
