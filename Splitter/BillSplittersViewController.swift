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
        
        self.navigationItem.title = "\(billName!) Splitters"
        self.navigationItem.hidesBackButton = true
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BillSplitter")
        let predicate = NSPredicate(format: "bill == %@", bill)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            allBillSplitters = results as! [BillSplitter]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        setAllSplitterTotals()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToNewBillSplitter" {
            
            let destinationVC = segue.destination as! NewBillSplitterViewController
            let passedBill: NSManagedObject = bill as NSManagedObject
                
            destinationVC.bill = passedBill
            destinationVC.billName = billName
        }
        
        if segue.identifier == "segueToBillSplitterItems" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                let destinationVC = segue.destination as! BillSplitterItemsViewController
                let splitter: BillSplitter = allBillSplitters[selectedIndexPath.row]
                let bill = self.bill as! Bill
                
                destinationVC.splitter = splitter
                destinationVC.bill = bill
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allBillSplitters.count > 0 {
            return allBillSplitters.count
        } else {
            TableViewHelper.EmptyMessage("\(billName!) has no bill splitters assigned to it yet.\nTap New Bill Splitter to add and assign items to a person.", tableView: tableView)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: BillSplitterCell = tableView.dequeueReusableCell(withIdentifier: "BillSplitterCell") as! BillSplitterCell
        let billSplitter = allBillSplitters[indexPath.row]
        
        cell.name.text = billSplitter.name
        cell.email.text = billSplitter.email
        if billSplitter.total == 0 || billSplitter.total == nil {
            cell.total.text = "£0.00"
        } else {
            cell.total.text = "£\(billSplitter.total!)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let billSplitter = allBillSplitters[indexPath.row]
            let managedContext = bill.managedObjectContext
            
            removeBillSplitter(billSplitter)
            managedContext!.delete(billSplitter as NSManagedObject)
            
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
    
    func removeBillSplitter(_ billSplitter: BillSplitter) {
        if let index = allBillSplitters.index(of: billSplitter) {
            allBillSplitters.remove(at: index)
        }
    }
    
    @IBAction func toggleEditingMode(_ sender: AnyObject) {
        
        if self.tableView.isEditing == true {
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "Done"
        } else {
            self.tableView.isEditing = true
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
