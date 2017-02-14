//
//  DeviceHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 02/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation

//Returns true if the app is being run on a phone/pad. If it's a simulator then there is no camera and the app reacts accordingly.
struct Platform {
    
    static var isPhone: Bool {
        return TARGET_OS_SIMULATOR == 0
    }
    
}
