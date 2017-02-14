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
        
        if allBills.count > 0 {
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        return allBills
    }
    
    func saveBillSplitter(context: AnyObject, values: [String: Any]) {
        
        let managedObjectContext = context.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "BillSplitter", in: managedObjectContext!)
        let billSplitter = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        
        if Platform.isPhone {
            let imageData = UIImageJPEGRepresentation(values["image"] as! UIImage, 0.5)
            billSplitter.setValue(imageData, forKey: "image")
        }
        
        values.forEach { value in
            billSplitter.setValue(value.value, forKey: value.key)
        }
        
        do {
            try managedObjectContext?.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
