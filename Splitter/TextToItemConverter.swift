//
//  TextToItemConverter.swift
//  Splitter
//
//  Created by Wayne Rumble on 03/11/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class TextToItemConverter {
    
    var itemBillID = String()
    
    func seperateTextToLines(receiptText: String) {
        var receiptLines:[String] = []
        receiptText.enumerateLines { receiptLines.append($0.line) }
        for line in receiptLines { createItems(line) }
    }
    
    func createItems(itemText: String) {
        if itemText.characters.count != 0 {
            let item = Item()
            item.billId = itemBillID
            item.name = returnItemName(itemText)
            item.quantity = returnItemQuantity(itemText)
            item.price = returnItemPrice(itemText)
        }
    }
    
    func returnItemName(itemText: String) -> String {
        let words = itemText.characters.split{$0 == " "}.map(String.init)
        var name = [String]()
        
        for word in words {
            if word.isaWord {
                name.append(word)
            }
        }
        
        return name.joinWithSeparator(" ")
    }
    
    func returnItemQuantity(itemText: String) -> Int {
        let int = itemText.stringByReplacingOccurrencesOfString(",", withString: ".")
        return NSString(string: int).integerValue
    }
    
    func returnItemPrice(itemText: String) -> Double {
        let removedCommas = itemText.stringByReplacingOccurrencesOfString(",", withString: ".")
        let words = removedCommas.characters.split{$0 == " "}.map(String.init)
        var double = String()
        
        for number in words {
            if number.containsADouble {
                double = number
            }
        }
        
        return priceFromString(double)
    }
    
    func removeCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("0123456789".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    func priceFromString(string: String) -> Double {
        var newString = removeCharsFromString(string)
        let index = newString.characters.count - 2
        newString.insert(".", atIndex: newString.startIndex.advancedBy(index))
        let price = (NSNumberFormatter().numberFromString(newString)?.doubleValue)!
        
        return price
    }
}

extension String {
    var containsADouble: Bool {
        return rangeOfString("[0-9]{1,}.[0-9]{1,}", options: .RegularExpressionSearch) != nil
    }
}

extension String {
    var isaWord: Bool {
        return rangeOfString("^[a-zA-Z]+$", options: .RegularExpressionSearch) != nil
    }
}
