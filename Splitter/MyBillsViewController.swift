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
    var newBackButton = UIBarButtonItem()
    
    @IBOutlet var newBillButton: UIButton!
    @IBOutlet var tableView: UITableView!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        newBackButton.title = ""
        
        self.navigationItem.title = "Splitter"
        
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationItem.backBarButtonItem = newBackButton
        
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
                destinationVC.billName = allBills[selectedIndexPath.row].name
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
        cell.location.text = bill.location
        cell.total!.text = "£\(Double(bill.total!))"
        
        return cell
    }
}

