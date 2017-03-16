//
//  CarouselDelegate.swift
//  Splitter
//
//  Created by Wayne Rumble on 14/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import iCarousel

class CarouselDelegate: NSObject, iCarouselDelegate {
    
//Sets carousels items that are in the background to be faded.
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        switch option {
            case .spacing:
                return value * 1.05
            case .fadeMin:
                return 0.0
            case .fadeMinAlpha:
                return 0.3
            case .fadeMax:
                return 0.0
            default:
                return value
        }
    }
}
