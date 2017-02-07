//
//  CurrencyHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 07/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation

extension Double {
    var asLocalCurrency:String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self))!
    }
}
