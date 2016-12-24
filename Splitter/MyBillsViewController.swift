//
//  ViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 04/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class MyBillsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var allBills = [Bill]()
    
    @IBOutlet var newBillButton: UIButton!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Splitter"
        self.navigationItem.hidesBackButton = true
                
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Bill")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            allBills = results as! [Bill]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if allBills.count > 0 {
            setbillTotals()
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueToBill" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                let destinationVC = segue.destinationViewController as! BillViewController
                let bill: NSManagedObject = allBills[selectedIndexPath.row] as NSManagedObject
                
                destinationVC.bill = bill
                destinationVC.billName = allBills[selectedIndexPath.row].name
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if allBills.count > 0 {
            return allBills.count
        } else {
            TableViewHelper.EmptyMessage("You don't have any bills yet.\nTap New Bills to begin.", tableView: tableView)
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: BillCell = tableView.dequeueReusableCellWithIdentifier("BillCell") as! BillCell
        let bill = allBills[indexPath.row]
        let formatter = NSDateFormatter()
        formatter.timeStyle = .NoStyle
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.stringFromDate(bill.date!)

        cell.name.text = bill.name
        cell.date.text = date
        cell.location.text = bill.location
        cell.total!.text = "£\(Double(bill.total!))"
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let bill = allBills[indexPath.row]
            let managedContext = bill.managedObjectContext
            let billObject = (managedContext?.objectWithID(bill.objectID))! as NSManagedObject
            
            managedContext?.deleteObject(billObject)
            removeBill(bill)
            
            do {
                try managedContext!.save()
            }
            catch let error as NSError {
                print("Core Data save failed: \(error)")
            }
            tableView.reloadData()
        }
    }
    
    func removeBill(bill: Bill) {
        if let index = allBills.indexOf(bill) {
            allBills.removeAtIndex(index)
        }
    }
    
    func setbillTotals() {
        allBills.forEach { bill in
            var total = Double()
            let items = bill.items?.allObjects as! [Item]
            items.forEach { item in
                total += Double(item.price!)
            }
            total = Double(round(100*total)/100)
            bill.setValue(total, forKey: "total")
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
}

