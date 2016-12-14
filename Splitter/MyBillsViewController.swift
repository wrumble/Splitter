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
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Bill")
        
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            allBills = results as! [Bill]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueToBill" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                let destinationVC = segue.destinationViewController as! BillViewController
                let bill: NSManagedObject = allBills[selectedIndexPath.row] as NSManagedObject
                
                destinationVC.bill = bill
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allBills.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: BillCell = tableView.dequeueReusableCellWithIdentifier("BillCell") as! BillCell
        let bill = allBills[indexPath.row]
        cell.name.text = bill.name
        cell.date.text = bill.date
        cell.total!.text = "£\(bill.total!)"
        
        return cell
    }
    
    @IBAction func newBillsButtonWasPressed() {
        self.performSegueWithIdentifier("segueToNewBill", sender: self)
    }

}

