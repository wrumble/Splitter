//
//  BillSplitterViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 19/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData
import iCarousel

class BillSplittersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, iCarouselDataSource, iCarouselDelegate {
    
    var bill: NSManagedObject!
    var billName: String!
    var allBillSplitters: [BillSplitter]!
    var height: Double!
    var width: Double!
    var carouselIndex: Int!
    var isEditingSplitter = false
    var itemIndex: Int?
    var mainBillSplitterItems: [Item]!

    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet var carousel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllSplitters()
        
        height = Double(UIScreen.main.bounds.height) * 0.75
        width = Double(UIScreen.main.bounds.width) * 0.88
        
        billNameLabel.text = "\(billName!)"
        billNameLabel.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.75)
        
        if allBillSplitters.count < 3 {
            carousel.type = .coverFlow
        } else {
            carousel.type = .cylinder
            carousel.contentOffset = CGSize(width: 0, height: height * -0.67)
            carousel.viewpointOffset = CGSize(width: 0, height: height * -0.7)
        }
        
        carousel.isPagingEnabled = true
        carousel.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        carousel.scroll(byNumberOfItems: allBillSplitters.count, duration: 1.5)
    }
    
    func getAllSplitters() {
        
        allBillSplitters = [BillSplitter]()
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BillSplitter")
        let predicate = NSPredicate(format: "ANY bills == %@", bill)
        
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
    
    func numberOfItems(in carousel: iCarousel) -> Int {

        return allBillSplitters.count
    }
    

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let splitter = allBillSplitters[index]

        carouselIndex = index

        let splitterView = SplitterCarouselItemView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let viewWidth = Int(splitterView.frame.width)
    
        let nameLabel = SplitterCarouselItemNameLabel(frame: CGRect(x: 5, y: 10, width: viewWidth - 48, height: 40))
        let emailLabel = SplitterCarouselItemEmailLabel(frame: CGRect(x: 5, y: 50, width: viewWidth, height: 20))
        let editItemButton = SplitterCarouselEditButton(frame: CGRect(x: viewWidth - 48, y: 5, width: 45, height: 45))
        editItemButton.tag = index
        if !splitter.hasPaid || splitter.isMainBillSplitter {
            editItemButton.addTarget(self, action: #selector(editButtonWasPressed), for: .touchUpInside)
        }
        
        let itemHeight = Int(splitterView.frame.height)
        let payButton = SplitterCarouselItemPayButton(frame: CGRect(x: 0, y: itemHeight - 50, width: viewWidth + 1, height: 50))
        payButton.tag = index
        payButton.titleLabel?.numberOfLines = 0
        
        if !splitter.hasPaid {
            payButton.addTarget(self, action: #selector(payButtonWasPressed), for: .touchUpInside)
        }

        let tableViewHeight = Int(height - 125)
        let frame = CGRect(x: 0, y: 75, width: viewWidth, height: tableViewHeight)
        
        let tableView = SplitterCarouselItemTableView(frame: frame, style: .plain, splitter: splitter)
        tableView.register(SplitterCarouselItemTableViewCell.classForCoder(), forCellReuseIdentifier: "splitterCarouselItemTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = index
        
        splitterView.addSubview(nameLabel)
        splitterView.addSubview(emailLabel)
        if !splitter.hasPaid { splitterView.addSubview(editItemButton) }
        if splitter.isMainBillSplitter { splitterView.addSubview(editItemButton) }
        splitterView.addSubview(tableView)
        splitterView.addSubview(payButton)

        nameLabel.text = "\(allBillSplitters[index].name!)"
        emailLabel.text = "\(allBillSplitters[index].email!)"
        
        payButton.setTitle("Pay \(allBillSplitters[index].total.asLocalCurrency)", for: .normal)
        
        if splitter.hasPaid && !splitter.isMainBillSplitter{
            payButton.setTitle("\(allBillSplitters[index].name!) has paid", for: .normal)
        } else if splitter.isMainBillSplitter {
            payButton.setTitle("\(allBillSplitters[index].name!) pays the server", for: .normal)
        }

        return splitterView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToNewBillSplitter" {
            
            let destinationVC = segue.destination as! NewBillSplitterViewController
            let passedBill: NSManagedObject = bill as NSManagedObject
            
            destinationVC.bill = passedBill
            destinationVC.billName = billName
            
            if isEditingSplitter { destinationVC.splitter = allBillSplitters[itemIndex!] }
        }
        
        if segue.identifier == "segueToSplitterPaymentViewController" {
            
            let destinationVC = segue.destination as! SplitterPaymentViewController
            let passedBill: NSManagedObject = bill as NSManagedObject
            
            destinationVC.bill = passedBill
            destinationVC.splitter = allBillSplitters[itemIndex!]
            destinationVC.total = allBillSplitters[itemIndex!].total
        }
    }
    
    func payButtonWasPressed(_ sender: UIButton) {
        itemIndex = sender.tag
        super.performSegue(withIdentifier: "segueToSplitterPaymentViewController", sender: nil)
    }
    
    func editButtonWasPressed(_ sender: UIButton) {
        isEditingSplitter = true
        itemIndex = sender.tag
        super.performSegue(withIdentifier: "segueToNewBillSplitter", sender: nil)
    }
    
    @IBAction func addButtonWasPressed(_ sender: UIButton) {
        super.performSegue(withIdentifier: "segueToNewBillSplitter", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let splitter = allBillSplitters[carouselIndex]
        if (splitter.items?.count)! > 0 {
            return (splitter.items?.count)!
        } else {
            TableViewHelper.EmptyMessage("\(splitter.name!) has no items to pay for.", tableView: tableView)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SplitterCarouselItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "splitterCarouselItemTableViewCell") as! SplitterCarouselItemTableViewCell
        var item = ((allBillSplitters[tableView.tag].items)?.allObjects as! [Item])[indexPath.row]
        if allBillSplitters[tableView.tag].isMainBillSplitter {
            getMainBillSplitterItems(splitter: allBillSplitters[tableView.tag])
            item = mainBillSplitterItems[indexPath.row]
        }
        let count = Double((item.billSplitters?.count)!)
                        
        if count > 1 {
            cell.name!.text = "\(item.name!)\nsplit \(count) ways"
            cell.price!.text = "\((item.price/count).asLocalCurrency)"
            
        } else {
            cell.name!.text = item.name!
            cell.price!.text = "\(item.price.asLocalCurrency)"
        }
        
        let cellWidth = cell.frame.width
        let textWidth = cell.price.text?.widthWithConstrainedHeight(height: cell.view.frame.height, font: UIFont.systemFont(ofSize: 15))
        let height = cell.view.frame.height - 4
        let priceWidth = cellWidth - textWidth! - 5
        let nameWidth = priceWidth - 5
        
        cell.price.frame = CGRect(x: priceWidth, y: 2, width: textWidth!, height: height)
        cell.name.frame = CGRect(x: 5, y: 2, width: nameWidth, height: height)
        
        return cell
    }
    
    @IBAction func minusButtonWasTapped(_ sender: UIButton) {
        
        let index = carousel.currentItemIndex
        if index == 0 {
            
            let alert = UIAlertController(title: "Sorry", message: "You're not allowed to delete the person who owns this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            let splitter = allBillSplitters[index]
            let alert = UIAlertController(title: "Delete \(splitter.name!)?", message: nil, preferredStyle: .alert)
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                let managedContext = self.bill.managedObjectContext
                
                self.allBillSplitters.remove(at: index)
                managedContext!.delete(splitter as NSManagedObject)
                
                do {
                    try managedContext!.save()
                }
                catch let error as NSError {
                    print("Core Data delete failed: \(error)")
                }
                self.setAllSplitterTotals()
                if self.allBillSplitters.count < 3 { self.carousel.type = .coverFlow }
                self.carousel.reloadData()
                self.carousel.scroll(byNumberOfItems: self.allBillSplitters.count, duration: 1.5)
            })
            alert.addAction(noAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func setAllSplitterTotals() {
        allBillSplitters.forEach { billSplitter in
            let items = billSplitter.items?.allObjects as! [Item]
            let billSplitterObject = billSplitter as NSManagedObject
            var total = Double()
            items.forEach { item in
                total += Double(item.price)/Double((item.billSplitters?.count)!)
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
    
    func getMainBillSplitterItems(splitter: BillSplitter) {
     
        let managedContext = splitter.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        fetchRequest.predicate = NSPredicate(format: "bill == %@", bill)
        
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            mainBillSplitterItems = results as! [Item]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
