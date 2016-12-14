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
    
    var image: UIImageView?
    var imageStore: ImageStore?
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        name = ""
        date = assignDate()
        id = ""
    }
    
    func assignDate() -> String {
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .NoStyle
        formatter.dateStyle = .LongStyle
        
        return formatter.stringFromDate(currentDateTime)
    }
    
    func setBillImage() {
        self.image?.image = imageStore!.imageForKey(id!)
    }
    
}
