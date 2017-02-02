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
    

    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        billNameLabel.text = "\(billName!)"
        billNameLabel.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.75)
        fetchBillItems()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueToReceiptImage" {
            
            let destinationVC = segue.destination as! BillReceiptViewController
            
            destinationVC.bill = bill as! Bill
            
        } else if segue.identifier == "segueToBillSplitters" {
            
            var allBillSplitters = [BillSplitter]()
            
            let managedContext = bill.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BillSplitter")
            let predicate = NSPredicate(format: "ANY bills == %@", bill)
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
            
            let destinationVC = segue.destination as! BillSplittersViewController
            let passedBill: NSManagedObject = bill as NSManagedObject
            
            destinationVC.billName = billName
            destinationVC.bill = passedBill
            destinationVC.allBillSplitters = allBillSplitters
        }
    }
    
    @IBAction func addNewItem(_ sender: UIButton) {
        
        let alertController = createAddItemAlertSubView()
        
        let alertControllerView = alertController.view.viewWithTag(0)
        
        let itemName = alertControllerView?.viewWithTag(1) as! UITextField
        let itemPrice = alertControllerView?.viewWithTag(2) as! UITextField
        let itemQuantityText = alertControllerView?.viewWithTag(3) as! UITextField
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
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
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allItems.count > 0 {
            return allItems.count
        } else {
            TableViewHelper.EmptyMessage("\(billName) has no items.\nTap Add to manually add items or try to re-take the phot by creating a new bill again.", tableView: tableView)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! ItemCell
        fetchBillItems()
        let item = allItems[indexPath.row]
        
        cell.name.text = item.name
        cell.price.text = "£\(item.price)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = allItems[indexPath.row]
        let alertController = createEditItemAlertSubView()
        let alertControllerView = alertController.view.viewWithTag(0)
        
        let itemName = alertControllerView?.viewWithTag(1) as! UITextField
        let itemPrice = alertControllerView?.viewWithTag(2) as! UITextField
        
        itemName.text = item.name
        itemPrice.text = String(item.price)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            self.updateEditedItem(indexPath: indexPath, itemName: itemName.text!, itemPrice: Double(itemPrice.text!)!)
            self.fetchBillItems()
            self.tableView.reloadData()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = allItems[indexPath.row]
            let managedContext = self.bill.managedObjectContext
            
            removeItem(item)
            managedContext?.delete(item)
            
            do {
                try managedContext!.save()
            }
            catch let error as NSError {
                print("Core Data save failed: \(error)")
            }
            setBillTotal()
            tableView.reloadData()
        }
    }
    
    func fetchBillItems() {
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        fetchRequest.predicate = NSPredicate(format: "bill == %@", bill)
        
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            allItems = results as! [Item]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func removeItem(_ item: Item) {
        if let index = allItems.index(of: item) {
            allItems.remove(at: index)
        }
    }
    
    func updateEditedItem(indexPath: IndexPath, itemName: String, itemPrice: Double){
        let managedContext = self.bill.managedObjectContext
        let currentItems = self.bill.mutableSetValue(forKey: "items")
        currentItems.removeAllObjects()
        
        allItems[indexPath.row].name = itemName
        allItems[indexPath.row].price = itemPrice
        
        currentItems.addObjects(from: allItems)
        
        do {
            try managedContext!.save()
        }
        catch let error as NSError {
            print("Core Data save failed: \(error)")
        }
        setBillTotal()
    }
    
    func createAlertViewItem(_ alertController: UIAlertController, itemName: String, itemStringPrice: String) {

        let managedContext = self.bill.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext!)
        let newItem = NSManagedObject(entity: entity!, insertInto: managedContext)
        let currentItems = self.bill.mutableSetValue(forKey: "items")
        let itemPriceNumber = priceFromString(itemStringPrice)
        
        newItem.setValue(itemName, forKey: "name")
        newItem.setValue(itemPriceNumber, forKey: "price")
        currentItems.add(newItem)
        
        do {
            try managedContext!.save()
        }
        catch let error as NSError {
            print("Core Data save failed: \(error)")
        }
        setBillTotal()
    }
    
    func createAddItemAlertSubView() -> UIAlertController {
        
        let view = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(50), width: CGFloat(250), height: CGFloat(100)))
        view.tag = 0
        
        let itemName = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(0), width: CGFloat(252), height: CGFloat(25)))
        itemName.borderStyle = .roundedRect
        itemName.placeholder = "Item Name"
        itemName.keyboardAppearance = .alert
        itemName.tag = 1
        itemName.delegate = self
        view.addSubview(itemName)
        
        let itemPrice = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(30), width: CGFloat(252), height: CGFloat(25)))
        itemPrice.placeholder = "Item Price"
        itemPrice.borderStyle = .roundedRect
        itemPrice.keyboardAppearance = .alert
        itemPrice.keyboardType = UIKeyboardType.numberPad
        itemPrice.tag = 2
        itemPrice.delegate = self
        view.addSubview(itemPrice)
        
        let itemQuantity = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(60), width: CGFloat(252), height: CGFloat(25)))
        itemQuantity.placeholder = "Item Quantity"
        itemQuantity.borderStyle = .roundedRect
        itemQuantity.keyboardAppearance = .alert
        itemQuantity.keyboardType = UIKeyboardType.numberPad
        itemQuantity.tag = 3
        itemQuantity.delegate = self
        view.addSubview(itemQuantity)
        
        let alertController = UIAlertController(title: "Add Item\n\n\n\n", message: nil, preferredStyle: .alert)
        
        alertController.view.addSubview(view)
        
        return alertController
    }
    
    func createEditItemAlertSubView() -> UIAlertController {
        
        let view = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(50), width: CGFloat(250), height: CGFloat(100)))
        view.tag = 0
        
        let itemName = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(0), width: CGFloat(252), height: CGFloat(25)))
        itemName.borderStyle = .roundedRect
        itemName.placeholder = "Item Name"
        itemName.keyboardAppearance = .alert
        itemName.tag = 1
        itemName.delegate = self
        view.addSubview(itemName)
        
        let itemPrice = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(30), width: CGFloat(252), height: CGFloat(25)))
        itemPrice.placeholder = "Item Price"
        itemPrice.borderStyle = .roundedRect
        itemPrice.keyboardAppearance = .alert
        itemPrice.keyboardType = UIKeyboardType.numberPad
        itemPrice.tag = 2
        itemPrice.delegate = self
        view.addSubview(itemPrice)
        
        let alertController = UIAlertController(title: "Edit Item\n\n", message: nil, preferredStyle: .alert)
        
        alertController.view.addSubview(view)
        
        return alertController
    }
    
    func priceFromString(_ string: String) -> Double {
        let price = (NumberFormatter().number(from: string)?.doubleValue)!
        return price
    }
    
    func setBillTotal() {
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let predicate = NSPredicate(format: "bill == %@", bill)
        fetchRequest.predicate = predicate
        
        var items = [Item]()
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            items = results as! [Item]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        var total = Double()
        items.forEach { item in
            total += Double(item.price)
        }
        total = Double(round(100*total)/100)
        bill.setValue(total, forKey: "total")
        do {
            try managedContext!.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}


