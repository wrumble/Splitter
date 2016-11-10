//
//  ItemStore.swift
//  Splitter
//
//  Created by Wayne Rumble on 10/11/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class ItemStore: NSObject {
    
    let cache = NSCache()
    
    func setItem(item: [Item], forKey key: String) {
        cache.setObject(item, forKey: key)
    }
    
    func itemForKey(key: String) -> [Item]? {
        return cache.objectForKey(key) as? [Item]
    }
    
    func deleteItemForKey(key: String) {
        cache.removeObjectForKey(key)
    }
    
}