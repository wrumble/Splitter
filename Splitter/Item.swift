//
//  Item.swift
//  Splitter
//
//  Created by Wayne Rumble on 27/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class Item: NSManagedObject {
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID().uuidString
    }
    
}
