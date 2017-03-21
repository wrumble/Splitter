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
    
    let coreDataHelper = CoreDataHelper()

    var bill: Bill!
    var allItems: [Item]!

    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBillLabel()
        fetchBillItems()
    }
    
//Adds text and background color to the bills nameLabel.
    func setBillLabel() {
        
        billNameLabel.text = "\(bill.name!)"
        billNameLabel.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.75)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueToReceiptImage" {
            
            let destinationVC = segue.destination as! BillReceiptViewController
            
            destinationVC.bill = bill
            
        } else if segue.identifier == "segueToBillSplitters" {
            
            let destinationVC = segue.destination as! BillSplittersViewController
            
            destinationVC.bill = bill
        }
    }
    
    @IBAction func addNewItem(_ sender: UIButton) {
        
        let alertController = createAddItemAlertSubView()
        
        let alertControllerView = alertController.view.viewWithTag(0)
        
        let itemName = alertControllerView?.viewWithTag(1) as! UITextField
        let itemPriceText = alertControllerView?.viewWithTag(2) as! UITextField
        let itemQuantityText = alertControllerView?.viewWithTag(3) as! UITextField
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let itemQuantity: Int
            
            if itemQuantityText.text == "" {
                itemQuantity = 1
            } else {
                itemQuantity = Int(itemQuantityText.text!)!
            }
            let itemPrice = Double(itemPriceText.text!)!
            let values = ["quantity": itemQuantity,
                          "name": itemName.text!,
                          "price": itemPrice,
                          "id": self.bill.id!] as [String: Any]
            
            self.coreDataHelper.saveItem(self.bill, values: values)
            
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
            
            let message = "\(bill.name) has no items.\nTap Add to manually add items or try to re-take the photo by creating a new bill again."
            
            TableViewHelper().createEmptyMessage(message, tableView: tableView)
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ItemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! ItemCell
        fetchBillItems()
        let item = allItems[indexPath.row]
        
        cell.name.text = item.name
        cell.price.text = "\(item.price.asLocalCurrency)"
        
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
            let managedContext = bill.managedObjectContext
            let quantity = item.quantity - 1
            
            allItems.forEach { otherItem in
                
                if item.creationDateTime == otherItem.creationDateTime {
                    
                    otherItem.setValue(quantity, forKeyPath: "quantity")
                }
            }
            
            removeItem(item)
            managedContext?.delete(item)
            
            do {
                try managedContext?.save()
            }
            catch let error as NSError {
                print("Core Data save failed: \(error)")
            }
            tableView.reloadData()
        }
    }
    
    func fetchBillItems() {
        
        allItems = bill.items?.allObjects as! [Item]
        allItems = allItems.sorted { $0.name! < $1.name! }
    }
    
    func removeItem(_ item: Item) {
        
        if let index = allItems.index(of: item) {
            
            allItems.remove(at: index)
        }
    }
    
    func updateEditedItem(indexPath: IndexPath, itemName: String, itemPrice: Double){
        
        let managedContext = self.bill.managedObjectContext
        let currentItems = self.bill.mutableSetValue(forKey: "items")
        
        allItems[indexPath.row].name = itemName.trim()
        allItems[indexPath.row].price = itemPrice
        
        currentItems.removeAllObjects()
        currentItems.addObjects(from: allItems)
        
        do {
            try managedContext!.save()
        }
        catch let error as NSError {
            print("Core Data save failed: \(error)")
        }
    }
    
    func createAlertViewItem(_ alertController: UIAlertController, itemName: String, itemStringPrice: String, itemQuantity: Int) {

        let managedContext = self.bill.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext!)
        let newItem = NSManagedObject(entity: entity!, insertInto: managedContext)
        let currentItems = self.bill.mutableSetValue(forKey: "items")
        let itemPriceNumber = priceFromString(itemStringPrice)
        
        newItem.setValue(itemName.trim(), forKey: "name")
        newItem.setValue(itemPriceNumber, forKey: "price")
        newItem.setValue(itemQuantity, forKey: "quantity")
        
        currentItems.add(newItem)
        
        do {
            try managedContext!.save()
        }
        catch let error as NSError {
            print("Core Data save failed: \(error)")
        }
    }
    
    func createAddItemAlertSubView() -> UIAlertController {
        
        let view = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(50), width: CGFloat(250), height: CGFloat(100)))
        view.tag = 0
        
        let itemName = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(0), width: CGFloat(252), height: CGFloat(25)))
        itemName.borderStyle = .roundedRect
        itemName.placeholder = "Item Name"
        itemName.keyboardAppearance = .alert
        itemName.autocapitalizationType = .words
        itemName.tag = 1
        itemName.delegate = self
        view.addSubview(itemName)
        
        let itemPrice = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(30), width: CGFloat(252), height: CGFloat(25)))
        itemPrice.placeholder = "Item Price"
        itemPrice.borderStyle = .roundedRect
        itemPrice.keyboardAppearance = .alert
        itemPrice.keyboardType = .numbersAndPunctuation
        itemPrice.tag = 2
        itemPrice.delegate = self
        view.addSubview(itemPrice)
        
        let itemQuantity = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(60), width: CGFloat(252), height: CGFloat(25)))
        itemQuantity.placeholder = "Item Quantity"
        itemQuantity.borderStyle = .roundedRect
        itemQuantity.keyboardAppearance = .alert
        itemQuantity.keyboardType = .numberPad
        itemQuantity.tag = 3
        itemQuantity.delegate = self
        view.addSubview(itemQuantity)
        
        let alertController = UIAlertController(title: "Add Item\n\n\n\n", message: nil, preferredStyle: .alert)
        
        alertController.view.addSubview(view)
        
        return alertController
    }
    
    func createEditItemAlertSubView() -> UIAlertController {
        
        let view = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(45), width: CGFloat(250), height: CGFloat(60)))
        view.tag = 0
        
        let itemName = UITextField(frame: CGRect(x: CGFloat(5), y: CGFloat(0), width: CGFloat(252), height: CGFloat(25)))
        itemName.borderStyle = .roundedRect
        itemName.placeholder = "Item Name"
        itemName.keyboardAppearance = .alert
        itemName.autocapitalizationType = .words
        itemName.tag = 1
        itemName.delegate = self
        view.addSubview(itemName)
        
        let itemPrice = UITextField(frame: CGRect(x: CGFloat(5), y: CGFloat(30), width: CGFloat(252), height: CGFloat(25)))
        itemPrice.placeholder = "Item Price"
        itemPrice.borderStyle = .roundedRect
        itemPrice.keyboardAppearance = .alert
        itemPrice.keyboardType = .decimalPad
        itemPrice.tag = 2
        itemPrice.delegate = self
        view.addSubview(itemPrice)
        
        let alertController = UIAlertController(title: "Edit Item\n\n", message: nil, preferredStyle: .alert)
        
        alertController.view.addSubview(view)
        
        return alertController
    }
    
    func priceFromString(_ string: String) -> Double {
        
        return (NumberFormatter().number(from: string)?.doubleValue)!
    }
}


