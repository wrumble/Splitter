//
//  BillSplitterViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 19/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class BillSplittersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bill: NSManagedObject!
    var billName: String!
    var allBillSplitters: [BillSplitter]!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "\(billName) Splitters"
        self.navigationItem.hidesBackButton = true
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "BillSplitter")
        let predicate = NSPredicate(format: "bill == %@", bill)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        do {
            let results =
                try managedContext!.executeFetchRequest(fetchRequest)
            allBillSplitters = results as! [BillSplitter]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        setAllSplitterTotals()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueToNewBillSplitter" {
            
            let destinationVC = segue.destinationViewController as! NewBillSplitterViewController
            let passedBill: NSManagedObject = bill as NSManagedObject
                
            destinationVC.bill = passedBill
            destinationVC.billName = billName
        }
        
        if segue.identifier == "segueToBillSplitterItems" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                let destinationVC = segue.destinationViewController as! BillSplitterItemsViewController
                let splitter: BillSplitter = allBillSplitters[selectedIndexPath.row]
                let bill = self.bill as! Bill
                
                destinationVC.splitter = splitter
                destinationVC.bill = bill
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allBillSplitters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: BillSplitterCell = tableView.dequeueReusableCellWithIdentifier("BillSplitterCell") as! BillSplitterCell
        let billSplitter = allBillSplitters[indexPath.row]
        
        cell.name.text = billSplitter.name
        cell.email.text = billSplitter.email
        if billSplitter.total == "" || billSplitter.total == nil {
            cell.total.text = "£0.00"
        } else {
            cell.total.text = "£\(billSplitter.total!)"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {

            let billSplitter = allBillSplitters[indexPath.row]
            let managedContext = bill.managedObjectContext
            
            removeBillSplitter(billSplitter)
            managedContext!.deleteObject(billSplitter as NSManagedObject)
            
            do {
                try managedContext!.save()
            }
            catch let error as NSError {
                print("Core Data save failed: \(error)")
            }
            self.setAllSplitterTotals()
            tableView.reloadData()
        }
    }
    
    func removeBillSplitter(billSplitter: BillSplitter) {
        if let index = allBillSplitters.indexOf(billSplitter) {
            allBillSplitters.removeAtIndex(index)
        }
    }
    
    @IBAction func toggleEditingMode(sender: AnyObject) {
        
        if self.tableView.editing == true {
            self.tableView.editing = false
            self.navigationItem.rightBarButtonItem?.title = "Done"
        } else {
            self.tableView.editing = true
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
    }
    
    func setAllSplitterTotals() {
        allBillSplitters.forEach { billSplitter in
            let items = billSplitter.items?.allObjects as! [Item]
            let billSplitterObject = billSplitter as NSManagedObject
            var total = Double()
            items.forEach { item in
                total += Double(item.price!)/Double((item.billSplitters?.count)!)
            }
            total = Double(round(100*total)/100)
            
            billSplitterObject.setValue(total, forKey: "total")
        }
        let managedContext = bill.managedObjectContext
        
        do {
            try managedContext!.save()
        }
        catch let error as NSError {
            print("Core Data save failed: \(error)")
        }
    }
}
