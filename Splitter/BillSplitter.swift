//
//  BillSplitter.swift
//  Splitter
//
//  Created by Wayne Rumble on 19/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import Foundation
import CoreData


class BillSplitter: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        name = ""
        email = ""
        id = ""
    }
}
