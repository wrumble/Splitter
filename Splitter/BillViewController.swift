//
//  BillViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 13/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import Foundation
import CoreData

class BillViewController: UIViewController, UITableViewDataSource {
    
    var bill: NSManagedObject!
    var allItems: [Item]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Item")
        do {
            let results =
                try managedContext!.executeFetchRequest(fetchRequest)
            allItems = results as! [Item]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: ItemCell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as! ItemCell
        let item = allItems[indexPath.row]

        cell.name.text = item.name
        cell.price.text = "£\(item.price)"
        
        return cell
    }
    
}


