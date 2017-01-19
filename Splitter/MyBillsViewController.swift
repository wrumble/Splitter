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
                
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
            setbillTotals()
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToBill" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                let destinationVC = segue.destination as! BillViewController
                let bill: NSManagedObject = allBills[selectedIndexPath.row] as NSManagedObject
                
                destinationVC.bill = bill
                destinationVC.billName = allBills[selectedIndexPath.row].name
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if allBills.count > 0 {
            return allBills.count
        } else {
            TableViewHelper.EmptyMessage("You don't have any bills yet.\nTap New Bills to begin.", tableView: tableView)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: BillCell = tableView.dequeueReusableCell(withIdentifier: "BillCell") as! BillCell
        let bill = allBills[indexPath.row]
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.string(from: bill.date! as Date)

        cell.name.text = bill.name
        cell.date.text = date
        cell.location.text = bill.location
        cell.total!.text = "£\(Double(bill.total))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bill = allBills[indexPath.row]
            let managedContext = bill.managedObjectContext
            
            managedContext?.delete(bill)
            keepMainBillSplitter(bill: bill)
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
    
    func keepMainBillSplitter(bill: Bill) {
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BillSplitter")
        let predicate = NSPredicate(format: "ANY bills == %@", bill)

        fetchRequest.predicate = predicate
        
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            var count = 0
            results.forEach { result in
                if count > 0 {
                    managedContext?.delete(result as! NSManagedObject)
                }
                
                count += 1
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func removeBill(_ bill: Bill) {
        if let index = allBills.index(of: bill) {
            allBills.remove(at: index)
        }
    }
    
    func setbillTotals() {
        allBills.forEach { bill in
            var total = Double()
            let items = bill.items?.allObjects as! [Item]
            items.forEach { item in
                total += Double(item.price)
            }
            total = Double(round(100*total)/100)
            bill.setValue(total, forKey: "total")
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
}

