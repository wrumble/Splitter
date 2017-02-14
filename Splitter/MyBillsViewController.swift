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
    
    let coredataHelper = CoreDataHelper()
    
    var carouselIndex: Int!
    var itemIndex: Int?
    var allBills = [Bill]()
    var height = Double(UIScreen.main.bounds.height) * 0.75
    var width = Double(UIScreen.main.bounds.width) * 0.88
    
    @IBOutlet weak var splitterTitleLabel: UILabel!
    @IBOutlet var carousel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allBills = coredataHelper.getAllBills()

        setCarouselStyle()
        setTitleLabel()
        checkEmptyCarousel()
        carousel.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        carousel.scroll(byNumberOfItems: allBills.count, duration: 1.5)
    }
    
    func setCarouselStyle() {
        
        if allBills.count < 3 {
            carousel.type = .coverFlow
        } else {
            carousel.type = .cylinder
            carousel.contentOffset = CGSize(width: 0, height: height * -0.67)
            carousel.viewpointOffset = CGSize(width: 0, height: height * -0.7)
        }
        
        carousel.isPagingEnabled = true
    }
    
    func checkEmptyCarousel() {
        if allBills.count == 0 {
            let noBillsLabel = EmptyCarouselLabel(frame: CGRect(x: 5, y: 0, width: carousel.frame.width - 5, height: carousel.frame.height))
            view.addSubview(noBillsLabel)
        }
    }
    
    func setTitleLabel() {
        
        splitterTitleLabel.text = "Splitter"
        splitterTitleLabel.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.75)
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        
        return allBills.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let bill = allBills[index]
        
        carouselIndex = index
        
        let billView = SplitterCarouselItemView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let viewWidth = Int(billView.frame.width)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let dateText = dateFormatter.string(from: allBills[index].date! as Date)
        let dateTextWidth = String(describing: dateText).widthWithConstrainedHeight(height: 20, font: UIFont.systemFont(ofSize: 15))
        
        let nameLabel = SplitterCarouselItemNameLabel(frame: CGRect(x: 5, y: 10, width: viewWidth - 48, height: 40))
        let locationLabel = SplitterCarouselItemEmailLabel(frame: CGRect(x: 5, y: 50, width: viewWidth - Int(dateTextWidth - 5), height: 20))
        let dateLabel = CarouselItemDateLabel(frame: CGRect(x: CGFloat(viewWidth) - dateTextWidth - 5, y: 50, width: dateTextWidth, height: 20))
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
        billView.addSubview(dateLabel)
        billView.addSubview(editButton)
        billView.addSubview(tableView)
        billView.addSubview(splitButton)
        
        nameLabel.text = "\(allBills[index].name!)"
        locationLabel.text = "\(allBills[index].location!)"
        dateLabel.text = "\(dateText)"
        
        splitButton.setTitle("Split \(allBills[index].total())", for: .normal)
        
        return billView
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
        let item = ((allBills[carouselIndex].items)?.allObjects as! [Item])[indexPath.row]
                
        cell.name!.text = item.name!
        cell.price!.text = "\(item.price.asLocalCurrency)"
        
        let cellWidth = cell.frame.width
        let textWidth = cell.price.text?.widthWithConstrainedHeight(height: cell.view.frame.height, font: UIFont.systemFont(ofSize: 15))
        let height = cell.view.frame.height - 4
        let priceWidth = cellWidth - textWidth! - 5
        let nameWidth = priceWidth - 5
        
        cell.price.frame = CGRect(x: priceWidth, y: 2, width: textWidth!, height: height)
        cell.name.frame = CGRect(x: 5, y: 2, width: nameWidth, height: height)
        
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
}

