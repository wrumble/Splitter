//
//  Bill.swift
//  Splitter
//
//  Created by Wayne Rumble on 27/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class Bill: NSObject {
    
    var imageStore: ImageStore!
    var itemStore: ItemStore!
    var name: String!
    var date: String!
    var location: String?
    var id = NSUUID().UUIDString
    var image: UIImageView?
    var total = Double()
        
    func setBillImage() {
        self.image?.image = imageStore.imageForKey(id)
    }
    
    func getBillItems() -> [Item] {
        return itemStore.itemForKey(self.id)!
    }
    
    func getBillTotal() {
        let itemArray = getBillItems()
        
        for item in itemArray {
            self.total += item.price
        }
    }
    
}
