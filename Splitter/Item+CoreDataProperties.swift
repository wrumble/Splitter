//
//  Item+CoreDataProperties.swift
//  Splitter
//
//  Created by Wayne Rumble on 21/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var price: NSNumber?
    @NSManaged var quantity: NSNumber?
    @NSManaged var bill: Bill?
    @NSManaged var billSplitters: NSSet?

}
