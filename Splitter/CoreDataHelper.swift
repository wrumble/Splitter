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
            setBillTotals(allBills: allBills)
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        return allBills
    }


    func setBillTotals(allBills: [Bill]) {
        allBills.forEach { bill in
            var total = Double()
            let items = bill.items?.allObjects as! [Item]
            items.forEach { item in
                total += Double(item.price)
            }
            bill.setValue(total, forKey: "total")
        }
    }
}
