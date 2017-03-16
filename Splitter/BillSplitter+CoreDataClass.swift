//
//  BillSplitter+CoreDataClass.swift
//  Splitter
//
//  Created by Wayne Rumble on 12/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation
import CoreData

@objc(BillSplitter)
public class BillSplitter: NSManagedObject {
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        
        name = ""
        email = ""
        id = ""
        isMainBillSplitter = false
        hasPaid = false
        accountID = ""
    }
    
    func total() -> Double {
        var total = 0.0
        let items = self.items?.allObjects as! [Item]
        items.forEach { item in
            
            let numberOfSplitters = (item.billSplitters?.allObjects as! [BillSplitter]).count
            total += item.price/Double(numberOfSplitters)
        }
        return total
    }
}
