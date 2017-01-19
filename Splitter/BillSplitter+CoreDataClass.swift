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
        total = 0
        isMainBillSplitter = false
        hasPaid = false
        accountID = ""
    }

}
