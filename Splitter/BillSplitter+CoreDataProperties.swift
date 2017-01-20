//
//  BillSplitter+CoreDataProperties.swift
//  Splitter
//
//  Created by Wayne Rumble on 19/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation
import CoreData


extension BillSplitter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BillSplitter> {
        return NSFetchRequest<BillSplitter>(entityName: "BillSplitter");
    }

    @NSManaged public var accountID: String?
    @NSManaged public var email: String?
    @NSManaged public var hasPaid: Bool
    @NSManaged public var id: String?
    @NSManaged public var isMainBillSplitter: Bool
    @NSManaged public var name: String?
    @NSManaged public var total: Double
    @NSManaged public var image: NSData?
    @NSManaged public var bills: NSSet?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for bills
extension BillSplitter {

    @objc(addBillsObject:)
    @NSManaged public func addToBills(_ value: Bill)

    @objc(removeBillsObject:)
    @NSManaged public func removeFromBills(_ value: Bill)

    @objc(addBills:)
    @NSManaged public func addToBills(_ values: NSSet)

    @objc(removeBills:)
    @NSManaged public func removeFromBills(_ values: NSSet)

}

// MARK: Generated accessors for items
extension BillSplitter {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
