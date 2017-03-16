//
//  BillCarouselDataSource.swift
//  Splitter
//
//  Created by Wayne Rumble on 14/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import iCarousel

class CarouselBillDataSource: NSObject, iCarouselDataSource {
    
    let tableViewDataSource = CarouselBillTableViewDataSource()
    let tableViewDelegate = CarouselBillTableViewDelegate()
    
    var viewWidth: Int!
    var viewHeight: Int!
    var index: Int!
    var allBills = CoreDataHelper().getAllBills()
    var height = Double(UIScreen.main.bounds.height) * 0.75
    var width = Double(UIScreen.main.bounds.width) * 0.88
    
//Set number of carousel views to the number of bills saved on the app.
    func numberOfItems(in carousel: iCarousel) -> Int {
        
        return allBills.count
    }
    
//Set what each carousel items view contains.
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        self.index = index
        
        let billView = returnBillView()
        
        viewWidth = Int(billView.frame.width)
        viewHeight = Int(billView.frame.height)
        
        addViewsToBillView(billView: billView)

        return billView
    }
    
//Returns the main view for each carousel item.
    func returnBillView() -> CarouselView {
        
        return CarouselView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
//Adds subviews tot the main carousel item view.
    func addViewsToBillView(billView: CarouselView) {
        
        let dateLabel = returnDateLabel()
        let viewArray = [returnNameLabel(),
                         dateLabel,
                         returnLocationLabel(dateWidth: Int(dateLabel.frame.width)),
                         returnEditButton(),
                         returnTableView(bill: allBills[index]),
                         returnSplitButton(bill: allBills[index])] as [AnyObject]
        
        viewArray.forEach { view in
            billView.addSubview(view as! UIView)
        }
    }
    
//Returns the item name label with bill name.
    func returnNameLabel() -> CarouselNameLabel {
        
        let nameLabel = CarouselNameLabel(frame: CGRect(x: 5, y: 10, width: viewWidth - 48, height: 40))
        nameLabel.text = "\(allBills[index].name!)"
        
        return nameLabel
    }
    
//Returns a formatted item date label with bill date.
    func returnDateLabel() -> CarouselDateLabel {
        
        let dateText = setDateFormat().string(from: allBills[index].date! as Date)
        let dateWidth = returnDateTextWidth(dateText: dateText)
        let dateLabel = CarouselDateLabel(frame: CGRect(x: viewWidth - dateWidth - 10, y: 50, width: dateWidth + 5, height: 20))
        
        dateLabel.text = "\(dateText)"
        
        return dateLabel
    }
    
//Returns the width of the date's text as an integer.
    func returnDateTextWidth(dateText: String) -> Int {
        
        return Int(String(describing: dateText).widthWithConstrainedHeight(height: 20, font: UIFont.systemFont(ofSize: 15)))
    }
    
//Sets the format of the bills date.
    func setDateFormat() -> DateFormatter {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        
        return dateFormatter
    }
    
//Returns the item location label with the bills location.
    func returnLocationLabel(dateWidth: Int) -> CarouselSubLabel {
        
        let locationLabel = CarouselSubLabel(frame: CGRect(x: 5, y: 50, width: viewWidth - dateWidth - 10, height: 20))
        
        locationLabel.text = "\(allBills[index].location!)"
        
        return locationLabel
    }
    
//Returns the standard item edit button and adds its target.
    func returnEditButton() -> CarouselEditButton {
        
        let editButton = CarouselEditButton(frame: CGRect(x: viewWidth - 48, y: 5, width: 45, height: 45))
        
        editButton.tag = index
        editButton.addTarget(MyBillsViewController(), action: #selector(MyBillsViewController.editButtonWasPressed), for: .touchUpInside)
        
        return editButton
    }
    
//Returns the items tableview containing the bills items and prices.
    func returnTableView(bill: Bill) -> CarouselBillTableView {
        
        let frame = CGRect(x: 0, y: 75, width: viewWidth, height: Int(height - 125))
        let tableView = CarouselBillTableView(frame: frame, style: .plain, bill: bill)
        
        tableView.delegate = tableViewDelegate
        tableView.dataSource = tableViewDataSource
        tableView.tag = index
        tableView.register(CarouselTableViewCell.classForCoder(), forCellReuseIdentifier: "carouselTableViewCell")
        
        return tableView
    }
    
//Returns the Split button with the bills total.
    func returnSplitButton(bill: Bill) -> CarouselBottomButton {
        
        let splitButton = CarouselBottomButton(frame: CGRect(x: 0, y: viewHeight - 50, width: viewWidth + 1, height: 50))
        
        splitButton.tag = index
        splitButton.titleLabel?.numberOfLines = 0
        splitButton.addTarget(MyBillsViewController(), action: #selector(MyBillsViewController.splitButtonWasPressed), for: .touchUpInside)
        splitButton.setTitle("Split \(bill.total())", for: .normal)
        if bill.isPaid() { splitButton.setTitle("\(bill.total()) paid.", for: .normal) }
        
        return splitButton
    }
}
