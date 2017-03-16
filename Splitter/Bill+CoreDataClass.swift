//
//  Bill+CoreDataClass.swift
//  Splitter
//
//  Created by Wayne Rumble on 12/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation
import CoreData

@objc(Bill)
public class Bill: NSManagedObject {
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        
        name = ""
        id = NSUUID().uuidString
        date = NSDate()
    }
    
    func isPaid() -> Bool {
        var paid = true
        let splitters = self.billSplitters?.allObjects as! [BillSplitter]
        splitters.forEach { splitter in
            if !splitter.hasPaid {
                paid = false
            }
        }
        if splitters.count == 1 { paid = false }
        return paid
    }
    
    func total() -> String {
        var total = Double()
        let items = self.items?.allObjects as! [Item]
        items.forEach { item in
            total += item.price
        }
        return total.asLocalCurrency
    }

}
