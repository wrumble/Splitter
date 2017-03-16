//
//  MyBillsCarouselViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 01/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import iCarousel

class MyBillsViewController: UIViewController {
    
    let coredataHelper = CoreDataHelper()
    let carouselDataSource = CarouselBillDataSource()
    let carouselDelegate = CarouselDelegate()
    
    var bill: Bill!
    var carouselIndex: Int!
    var itemIndex: Int?
    var allBills = [Bill]()
    
    @IBOutlet weak var splitterTitleLabel: UILabel!
    @IBOutlet var carousel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allBills = coredataHelper.getAllBills()
        
        //Set view and carousel style depending on number of bills.
        setCarousel()
        setCarouselStyle()
        setTitleLabel()
        checkEmptyCarousel()
        carousel.reloadData()
    }
    
//Spin the carousel 1 rotation when view appears.
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        carousel.scroll(byNumberOfItems: allBills.count, duration: 1.5)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //View bill to make edits etc, passing bill selected.
        if segue.identifier == "segueToBill" {
            
            let destinationVC = segue.destination as! BillViewController
            
            destinationVC.bill = allBills[itemIndex!]
            
        //View splitters attached to bill and edit them.
        } else if segue.identifier == "segueToBillSplitters" {
            
            let bill = allBills[itemIndex!]
            let destinationVC = segue.destination as! BillSplittersViewController
            
            destinationVC.bill = bill
            destinationVC.allBillSplitters = bill.billSplitters?.allObjects as! [BillSplitter]
        }
    }

//Mark: View set up.
//Set carousel style depending on number of bills.
    func setCarousel() {
        
        carousel.delegate = carouselDelegate
        carousel.dataSource = carouselDataSource
    }
    
    func setCarouselStyle() {
        
        if allBills.count < 3 {
            
            carousel.type = .coverFlow
        } else {
            
            let height = Double(UIScreen.main.bounds.height) * 0.75
            
            carousel.type = .cylinder
            carousel.contentOffset = CGSize(width: 0, height: height * -0.67)
            carousel.viewpointOffset = CGSize(width: 0, height: height * -0.7)
        }
        
        carousel.isPagingEnabled = true
    }
    
//If the carouse is empty, display a label with instructions.
    func checkEmptyCarousel() {
        
        if allBills.count == 0 { view.addSubview(EmptyCarouselLabel(frame: CGRect.zero)) }
    }

//Set the banner title.
    func setTitleLabel() {
        
        splitterTitleLabel.text = "Splitter"
        splitterTitleLabel.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.75)
    }
    
//MARK: Button actions.
//Go to Bill Splitter view when split button pressed.
    func splitButtonWasPressed(_ sender: UIButton) {
        
        itemIndex = sender.tag
        super.performSegue(withIdentifier: "segueToBillSplitters", sender: nil)
    }
    
//Go to Bill view when edit button is pressed.
    func editButtonWasPressed(_ sender: UIButton) {
        
        itemIndex = sender.tag
        super.performSegue(withIdentifier: "segueToBill", sender: nil)
    }
    
//Display alert when minus button tapped.
    @IBAction func minusButtonWasTapped(_ sender: UIButton) {
        
        if allBills.count > 0 {
            
            let alert = createAlert()
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//MARK: Create Alert.
//Create alert using Alerthelper.
    func createAlert() -> UIAlertController {
        
        bill = allBills[carousel.currentItemIndex]
        let alert = AlertHelper().delete(title: "Delete \(bill.name!)?", message: nil, exit: false)
        
        addAlertActions(alert: alert)
        
        return alert
    }
    
//Add actions to alert
    func addAlertActions(alert: UIAlertController) {
        
        let noAction = getAlerNoAction()
        let yesAction = getAlertYesAction()
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
    }
    
//Create action when no button pressed.
    func getAlerNoAction() -> UIAlertAction {
        
        return UIAlertAction(title: "No", style: .cancel, handler: nil)
    }
    
//Create action which deletes bill from coredata and allBills array, then resets view and spins the carousel.
    func getAlertYesAction() -> UIAlertAction {
        
        return UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in

            self.removeBill()
            self.carousel.reloadData()
            self.carousel.scroll(byNumberOfItems: self.allBills.count, duration: 1.5)
        })
    }

//MARK: Delete bill.
//Remove bill from array.
    func removeBill() {
        
        if let index = allBills.index(of: bill) {
            
            allBills.remove(at: index)
            carouselDataSource.allBills = allBills
            checkEmptyCarousel()
        }
        self.coredataHelper.deleteBill(bill: bill)
    }
}

