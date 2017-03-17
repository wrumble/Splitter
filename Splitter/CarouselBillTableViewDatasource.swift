//
//  CarouselBillTableViewDatasource.swift
//  Splitter
//
//  Created by Wayne Rumble on 14/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class CarouselBillTableViewDataSource: NSObject, UITableViewDataSource {
    
    let allBills = CoreDataHelper().getAllBills()
    var cellWidth = CGFloat()
    var textWidth = CGFloat()
    var height = CGFloat()
    var priceWidth = CGFloat()
    var nameWidth = CGFloat()
    
//Return number of bills if greater than 0 otherwise return a message saying how to add a Bill.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = returnCollatedBillItems(tableView.tag).count
        
        if count > 0 {
            
            return count
        } else {
            
            let message = "You don't have any bills yet.\nTap the plus button to begin."
            
            TableViewHelper().createEmptyMessage(message, tableView: tableView)
            
            return 0
        }
    }
    
//Set what each cell in the tableview contains.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CarouselTableViewCell = tableView.dequeueReusableCell(withIdentifier: "carouselTableViewCell") as! CarouselTableViewCell
        let item = returnCollatedBillItems(tableView.tag)[indexPath.row]
        
        cell.name!.text = "\(item.quantity) x \(item.name!)"
        cell.price!.text = "\(item.price.asLocalCurrency)"
        
        setCellVariables(cell: cell)
        
        cell.name.frame = returnNameFrame(cell: cell)
        cell.price.frame = returnPriceFrame(cell: cell)
        
        return cell
    }
    
    func returnCollatedBillItems(_ tableViewTag: Int) -> [Item] {
        
        print(allBills[tableViewTag].items!.allObjects)
        let items = (allBills[tableViewTag].items)?.allObjects as! [Item]
        var collatedItems = [Item]()
        
        if items.count > 0 {
            
            var duplicateNames = Set<String>()
            
            items.forEach { item in
                
                if !duplicateNames.contains(item.name!) {
                    
                    collatedItems.append(item)
                    duplicateNames.insert(item.name!)
                }
            }
            
            collatedItems.sort(by: { $0.creationDateTime?.compare($1.creationDateTime as! Date) == .orderedAscending })
            
        }
        
        return collatedItems
    }
    
//Set necessary variables to create cell label sizes.
    func setCellVariables(cell: CarouselTableViewCell) {
        
        cellWidth = cell.frame.width
        textWidth = (cell.price.text?.widthWithConstrainedHeight(height: cell.view.frame.height, font: UIFont.systemFont(ofSize: 15)))!
        height = cell.view.frame.height - 4
        priceWidth = cellWidth - textWidth - 5
        nameWidth = priceWidth - 5
        
    }
    
//Return name labels frame.
    func returnNameFrame(cell: CarouselTableViewCell) -> CGRect {
        
        return CGRect(x: 5, y: 2, width: nameWidth, height: height)
    }
    
//Return price labels frame.
    func returnPriceFrame(cell: CarouselTableViewCell) -> CGRect {
        
        return CGRect(x: priceWidth, y: 2, width: textWidth, height: height)
    }
}
