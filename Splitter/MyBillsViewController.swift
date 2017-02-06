//
//  MyBillsCarouselViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 01/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData
import iCarousel

class MyBillsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, iCarouselDataSource, iCarouselDelegate {
    
    var allBills = [Bill]()
    var height: Double!
    var width: Double!
    var carouselIndex: Int!
    var itemIndex: Int?
    
    @IBOutlet weak var splitterTitleLabel: UILabel!
    @IBOutlet var carousel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllBills()
        
        height = Double(UIScreen.main.bounds.height) * 0.75
        width = Double(UIScreen.main.bounds.width) * 0.88
        
        splitterTitleLabel.text = "Splitter"
        splitterTitleLabel.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.75)

        if allBills.count < 3 {
            carousel.type = .coverFlow2
        } else {
            carousel.type = .cylinder
            carousel.contentOffset = CGSize(width: 0, height: height * -0.67)
            carousel.viewpointOffset = CGSize(width: 0, height: height * -0.7)
        }
        
        carousel.isPagingEnabled = true
        
        if allBills.count == 0 {
            let noBillsLabel = UILabel(frame: CGRect(x: 5, y: 0, width: carousel.frame.width - 5, height: carousel.frame.height))
            noBillsLabel.text = "You have no bills to split yet. Tap the plus icon to start splitting a new bill."
            noBillsLabel.textAlignment = .center
            noBillsLabel.numberOfLines = 0
            view.addSubview(noBillsLabel)
            view.setNeedsDisplay()
        }
        
        carousel.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        carousel.scroll(byNumberOfItems: allBills.count, duration: 1.5)
    }
    
    func getAllBills() {
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
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        
        return allBills.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let bill = allBills[index]
        
        carouselIndex = index
        
        let billView = SplitterCarouselItemView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let viewWidth = Int(billView.frame.width)
        
        let nameLabel = SplitterCarouselItemNameLabel(frame: CGRect(x: 5, y: 10, width: viewWidth - 48, height: 40))
        let locationLabel = SplitterCarouselItemEmailLabel(frame: CGRect(x: 5, y: 50, width: viewWidth, height: 20))
        let editButton = SplitterCarouselEditButton(frame: CGRect(x: viewWidth - 48, y: 5, width: 45, height: 45))
        editButton.tag = index
        editButton.addTarget(self, action: #selector(editButtonWasPressed), for: .touchUpInside)
        
        let itemHeight = Int(billView.frame.height)
        let splitButton = SplitterCarouselItemPayButton(frame: CGRect(x: 0, y: itemHeight - 50, width: viewWidth + 1, height: 50))
        splitButton.tag = index
        splitButton.titleLabel?.numberOfLines = 0
        splitButton.addTarget(self, action: #selector(splitButtonWasPressed), for: .touchUpInside)
        
        let tableViewHeight = Int(height - 125)
        let frame = CGRect(x: 0, y: 75, width: viewWidth, height: tableViewHeight)
        
        let tableView = BillCarouselItemTableView(frame: frame, style: .plain, bill: bill)
        tableView.delegate = self
        tableView.dataSource = self
        
        billView.addSubview(nameLabel)
        billView.addSubview(locationLabel)
        billView.addSubview(editButton)
        billView.addSubview(tableView)
        billView.addSubview(splitButton)
        
        nameLabel.text = "\(allBills[index].name!)"
        locationLabel.text = "\(allBills[index].location!)"
        
        splitButton.setTitle("Split £\(allBills[index].total)", for: .normal)
        
        return billView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if allBills.count > 2 {
            switch option {
            case .spacing:
                return value * 1.05
            case .fadeMin:
                return 0.0
            case .fadeMinAlpha:
                return 0.3
            case .fadeMax:
                return 0.0
            default:
                return value
            }
        }
        return value
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToBill" {
            
            let destinationVC = segue.destination as! BillViewController
            let bill: NSManagedObject = allBills[itemIndex!] as NSManagedObject
            
            destinationVC.bill = bill
            destinationVC.billName = allBills[itemIndex!].name
        } else if segue.identifier == "segueToBillSplitters" {
            
            var allBillSplitters = [BillSplitter]()
            
            let bill = allBills[itemIndex!]
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
            
            destinationVC.billName = bill.name
            destinationVC.bill = passedBill
            destinationVC.allBillSplitters = allBillSplitters
        }
    }
    
    func splitButtonWasPressed(_ sender: UIButton) {
        itemIndex = sender.tag
        super.performSegue(withIdentifier: "segueToBillSplitters", sender: nil)
    }
    
    func editButtonWasPressed(_ sender: UIButton) {
        itemIndex = sender.tag
        super.performSegue(withIdentifier: "segueToBill", sender: nil)
    }
    
    @IBAction func minusButtonWasTapped(_ sender: UIButton) {
        
        if allBills.count > 0 {
            let index = carousel.currentItemIndex
            let bill = allBills[index]
            let alert = UIAlertController(title: "Delete \(bill.name!)?", message: nil, preferredStyle: .alert)
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                let bill = self.allBills[index]
                let managedContext = bill.managedObjectContext
                
                managedContext?.delete(bill)
                self.keepMainBillSplitter(bill: bill)
                self.removeBill(bill)
                
                do {
                    try managedContext!.save()
                }
                catch let error as NSError {
                    print("Core Data save failed: \(error)")
                }
                if self.allBills.count < 3 { self.carousel.type = .coverFlow }
                self.carousel.reloadData()
                self.view.setNeedsDisplay()
                self.carousel.scroll(byNumberOfItems: self.allBills.count, duration: 1.5)
            })
            alert.addAction(noAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
        }
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let bill = allBills[carouselIndex]
        if bill.items!.count > 0 {
            return bill.items!.count
        } else {
            TableViewHelper.EmptyMessage("You don't have any bills yet.\nTap New Bills to begin.", tableView: tableView)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(SplitterCarouselItemTableViewCell.classForCoder(), forCellReuseIdentifier: "splitterCarouselItemTableViewCell")
        
        let cell: SplitterCarouselItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "splitterCarouselItemTableViewCell") as! SplitterCarouselItemTableViewCell
        let itemsSet = allBills[carouselIndex].items
        let items = itemsSet?.allObjects as! [Item]
        let item = items[indexPath.row]
        let count = item.billSplitters?.count
        
        cell.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.3)
        
        if count! > 1 {
            cell.name!.text = "\(item.name!)\nsplit \(count!) ways"
            cell.price!.text = "£\(Double(item.price)/Double(count!))"
            
        } else {
            cell.name!.text = item.name!
            cell.price!.text = "£\(item.price)"
        }
        cell.sizeToFit()
        return cell
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
}

