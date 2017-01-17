//
//  Bill+CoreDataProperties.swift
//  Splitter
//
//  Created by Wayne Rumble on 12/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation
import CoreData


extension Bill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bill> {
        return NSFetchRequest<Bill>(entityName: "Bill");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var total: Double
    @NSManaged public var billSplitters: NSSet?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for billSplitters
extension Bill {

    @objc(addBillSplittersObject:)
    @NSManaged public func addToBillSplitters(_ value: BillSplitter)

    @objc(removeBillSplittersObject:)
    @NSManaged public func removeFromBillSplitters(_ value: BillSplitter)

    @objc(addBillSplitters:)
    @NSManaged public func addToBillSplitters(_ values: NSSet)

    @objc(removeBillSplitters:)
    @NSManaged public func removeFromBillSplitters(_ values: NSSet)

}

// MARK: Generated accessors for items
extension Bill {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
