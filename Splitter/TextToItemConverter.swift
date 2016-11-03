//
//  TextToItemConverter.swift
//  Splitter
//
//  Created by Wayne Rumble on 03/11/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class TextToItemConverter {
    
    var itemBillID: String
    
    func seperateTextToLines(receiptText: String) {
        let text = receiptText
        var receiptLines:[String] = []
        text.enumerateLines { receiptLines.append($0.line) }
        for line in receiptLines { createItems(line) }
    }
    
    func createItems(itemText: String) {
        if itemText.characters.count != 0 {
            let item = Item()
            item.billId = itemBillID
            item.name = searchForItemName(itemText)
            item.quantity = searchForItemNumber(itemText)
            item.price = searchForItemPrice(itemText)
        }
    }
    
    func searchForItemName(itemText: String) {
        let words = itemText.characters.split{$0 == " "}.map(String.init)
        for word in words {
            if word == Int || word == Float {
                
            }
    }
    
    func searchForItemNumber(itemText: String) -> Int {
        return NSString(string: itemText).integerValue
    }
    
    func searchForItemPrice(itemText: String) -> Float {
        return NSString(string: itemText).floatValue
    }
}