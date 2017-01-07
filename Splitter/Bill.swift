//
//  Bill.swift
//  Splitter
//
//  Created by Wayne Rumble on 27/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class Bill: NSManagedObject {
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        name = ""
        date = Date()
        id = ""
    }
}
