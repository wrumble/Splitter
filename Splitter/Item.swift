//
//  Item.swift
//  Splitter
//
//  Created by Wayne Rumble on 27/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class Item: NSObject {
    
    var name: String!
    var quantity: Int!
    var price: Double!
    var billId = NSUUID().UUIDString
    
}
