//
//  Bill+CoreDataProperties.swift
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

extension Bill {

    @NSManaged var date: Date?
    @NSManaged var id: String?
    @NSManaged var location: String?
    @NSManaged var name: String?
    @NSManaged var total: NSNumber?
    @NSManaged var billSplitters: NSSet?
    @NSManaged var items: NSSet?

}
