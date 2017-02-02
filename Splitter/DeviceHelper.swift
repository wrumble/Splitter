//
//  DeviceHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 02/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation

struct Platform {
    
    static var isPhone: Bool {
        return TARGET_OS_SIMULATOR == 0
    }
    
}
