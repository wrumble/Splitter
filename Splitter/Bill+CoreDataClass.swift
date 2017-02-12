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
        date = NSDate()
    }

}
