//
//  Bill.swift
//  Splitter
//
//  Created by Wayne Rumble on 27/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class Bill {
    
    var imageStore: ImageStore!
    var name: String!
    var date: String!
    var location: String?
    var itemArray: [Item]?
    var billID = NSUUID().UUIDString
    var image: UIImageView?
        
    func setBillImage() {
        image?.image = imageStore.imageForKey(billID)
    }
    
}
