//
//  Item+CoreDataProperties.swift
//  Splitter
//
//  Created by Wayne Rumble on 16/03/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item");
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int32
    @NSManaged public var creationDateTime: NSDate?
    @NSManaged public var bill: Bill?
    @NSManaged public var billSplitters: NSSet?

}

// MARK: Generated accessors for billSplitters
extension Item {

    @objc(addBillSplittersObject:)
    @NSManaged public func addToBillSplitters(_ value: BillSplitter)

    @objc(removeBillSplittersObject:)
    @NSManaged public func removeFromBillSplitters(_ value: BillSplitter)

    @objc(addBillSplitters:)
    @NSManaged public func addToBillSplitters(_ values: NSSet)

    @objc(removeBillSplitters:)
    @NSManaged public func removeFromBillSplitters(_ values: NSSet)

}
