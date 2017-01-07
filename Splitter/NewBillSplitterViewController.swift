//
//  NewBillSplitterViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 19/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class NewBillSplitterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bill: NSManagedObject!
    var billName: String!
    var allItems: [Item]!
    var selectedItems = [Item]()
    var checked = [Bool]()
    
    @IBOutlet var billSplitterName: UITextField?
    @IBOutlet var billSplitterEmail: UITextField?
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchBillItems()
        
        for _ in 0...(allItems.count) {
            checked.append(false)
        }
        
        self.navigationItem.title = "New \(billName!) Splitter"
        self.navigationItem.hidesBackButton = true
        
        self.tableView.allowsMultipleSelection = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewBillSplitterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToBillSplitters" {
            let destinationVC = segue.destination as! BillSplittersViewController
            let passedBill: NSManagedObject = bill as NSManagedObject
            
            destinationVC.billName = billName
            destinationVC.bill = passedBill
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        fetchBillItems()
        
        let cell: NewBillSplitterItemCell = tableView.dequeueReusableCell(withIdentifier: "NewBillSplitterItemCell", for: indexPath) as! NewBillSplitterItemCell
        let item = allItems[indexPath.row]
        let numberOfSplitters = item.billSplitters?.count
        
        if numberOfSplitters == 0 {
            cell.currentSplitters.text = "No one is paying for this item yet."
        } else {
            
            var splitterList = "Split this item with "
            let itemSplitters = item.billSplitters?.allObjects as! [BillSplitter]
            for i in 0...Int((numberOfSplitters)!-1) {
                if numberOfSplitters == 1 {
                    splitterList += "\(itemSplitters[i].name!)"
                } else {
                    splitterList += ", \(itemSplitters[i].name!)"
                }
            }
            cell.currentSplitters.text = splitterList
        }
        
        cell.name.text = item.name
        cell.price.text = "£\(item.price!)"
        
        if !checked[indexPath.row] {
            cell.accessoryType = .none
        } else if checked[indexPath.row] {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                selectedItems.remove(at: selectedItems.index(of: allItems[indexPath.row])!)
                checked[indexPath.row] = false
            } else {
                cell.accessoryType = .checkmark
                selectedItems.append(allItems[indexPath.row])
                checked[indexPath.row] = true
            }
        }
    }
    
    func fetchBillItems() {
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "bill == %@", bill)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            allItems = results as! [Item]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func saveButtonWasPressed() {
        
        let managedContext = bill.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "BillSplitter", in: managedContext!)
        let newBillSplitter = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        setBillSplitterValues(newBillSplitter)
        setSelectedItemsToBillSplitter(newBillSplitter)
        
        do {
            try managedContext!.save()
        }
        catch let error as NSError {
            print("Core Data save failed: \(error)")
        }
        
        self.performSegue(withIdentifier: "segueToBillSplitters", sender: self)
    }
    
    func setSelectedItemsToBillSplitter(_ splitterObject: NSManagedObject) {
        
        selectedItems.forEach { item in
            let splitterItems = splitterObject.mutableSetValue(forKey: "items")
            splitterItems.add(item)
        }
    }
        
    func setBillSplitterValues(_ splitterObject: NSManagedObject) {
        
        let currentBillSplitters = self.bill.mutableSetValue(forKey: "billSplitters")
        
        splitterObject.setValue(billSplitterName?.text, forKey: "name")
        splitterObject.setValue(billSplitterEmail?.text, forKey: "email")
        currentBillSplitters.add(splitterObject)
    }
}
