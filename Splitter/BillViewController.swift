//
//  BillViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 13/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import Foundation
import CoreData

class BillViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var bill: NSManagedObject!
    var billName: String!
    var allItems: [Item]!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = billName
        
        fetchBillItems()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let destinationVC = segue.destinationViewController as! BillReceiptViewController
        let passedBill: NSManagedObject = bill as NSManagedObject
                
        destinationVC.billObject = passedBill
    }
    
    @IBAction func addNewItem(sender: UIButton) {
        
        let alertController = createAlertSubView()
        
        let alertControllerView = alertController.view.viewWithTag(0)
        
        let itemName = alertControllerView?.viewWithTag(1) as! UITextField
        let itemPrice = alertControllerView?.viewWithTag(2) as! UITextField
        let itemQuantityText = alertControllerView?.viewWithTag(3) as! UITextField
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let itemQuantity: Int
            
            if itemQuantityText.text == "" {
                itemQuantity = 0
            } else {
                itemQuantity = Int((itemQuantityText.text)!)!
            }
            if itemQuantity == 0 || itemQuantity == 1 {
                self.createAlertViewItem(alertController, itemName: itemName.text!, itemStringPrice: itemPrice.text!)
            } else {
                for _ in 1...itemQuantity {
                    self.createAlertViewItem(alertController, itemName: itemName.text!, itemStringPrice: itemPrice.text!)
                }
            }
            
            self.fetchBillItems()
            self.tableView.reloadData()
        })
        
        
        alertController.addAction(okAction)
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: ItemCell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as! ItemCell
        fetchBillItems()
        let item = allItems[indexPath.row]
        
        cell.name.text = item.name
        cell.price.text = "£\(item.price)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let item = allItems[indexPath.row]
            let currentItems = self.bill.mutableSetValueForKey("items")
            let managedContext = self.bill.managedObjectContext
            
            removeItem(item)
            currentItems.removeObject(item)
            do {
                try managedContext!.save()
            }
            catch let error as NSError {
                print("Core Data save failed: \(error)")
            }
            tableView.reloadData()
        }
    }
    
    func fetchBillItems() {
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Item")
        let predicate = NSPredicate(format: "bill == %@", bill)
        fetchRequest.predicate = predicate
        
        do {
            let results =
                try managedContext!.executeFetchRequest(fetchRequest)
            allItems = results as! [Item]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func removeItem(item: Item) {
        if let index = allItems.indexOf(item) {
            allItems.removeAtIndex(index)
        }
    }
    
    func createAlertViewItem(alertController: UIAlertController, itemName: String, itemStringPrice: String) {

        let managedContext = self.bill.managedObjectContext
        let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: managedContext!)
        let newItem = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        let currentItems = self.bill.mutableSetValueForKey("items")
        let itemPriceNumber = Int(itemStringPrice)
        
        newItem.setValue(itemName, forKey: "name")
        newItem.setValue(itemPriceNumber, forKey: "price")
        currentItems.addObject(newItem)
        
        do {
            try managedContext!.save()
        }
        catch let error as NSError {
            print("Core Data save failed: \(error)")
        }
        
    }
    
    func createAlertSubView() -> UIAlertController {
        
        let view = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(50), width: CGFloat(250), height: CGFloat(100)))
        view.tag = 0
        
        let itemName = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(0), width: CGFloat(252), height: CGFloat(25)))
        itemName.borderStyle = .RoundedRect
        itemName.placeholder = "Item Name"
        itemName.keyboardAppearance = .Alert
        itemName.tag = 1
        itemName.delegate = self
        view.addSubview(itemName)
        
        let itemPrice = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(30), width: CGFloat(252), height: CGFloat(25)))
        itemPrice.placeholder = "Item Price"
        itemPrice.borderStyle = .RoundedRect
        itemPrice.keyboardAppearance = .Alert
        itemPrice.tag = 2
        itemPrice.delegate = self
        view.addSubview(itemPrice)
        
        let itemQuantity = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(60), width: CGFloat(252), height: CGFloat(25)))
        itemQuantity.placeholder = "Item Quantity"
        itemQuantity.borderStyle = .RoundedRect
        itemQuantity.keyboardAppearance = .Alert
        itemQuantity.tag = 3
        itemQuantity.delegate = self
        view.addSubview(itemQuantity)
        
        let alertController = UIAlertController(title: "Add Item\n\n\n\n", message: nil, preferredStyle: .Alert)
        
        alertController.view.addSubview(view)
        
        return alertController
    }
    
}


