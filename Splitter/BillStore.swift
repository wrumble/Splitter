//
//  BillStore.swift
//  Splitter
//
//  Created by Wayne Rumble on 10/11/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class BillStore: NSObject {
    
    let cache = NSCache()
    
    func setBill(bill: Bill, forKey key: String) {
        cache.setObject(bill, forKey: key)
    }
    
    func billForKey(key: String) -> Bill? {
        return cache.objectForKey(key) as? Bill
    }
    
    func deleteBillForKey(key: String) {
        cache.removeObjectForKey(key)
    }
    
}