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
    var itemStore = ItemStore()
    var itemArray = [Item]()
    
    func seperateTextToLines(receiptText: String) {
        let newlineChars = NSCharacterSet.newlineCharacterSet()
        let lines = receiptText.utf16.split { newlineChars.characterIsMember($0) }.flatMap(String.init)
        for line in lines { createItems(line) }
        saveItemArray()
    }
    
    func createItems(itemText: String) {
        if itemText.characters.count > 5 {
            let item = Item()
            item.billId = itemBillID
            item.name = returnItemName(itemText)
            item.quantity = returnItemQuantity(itemText)
            item.price = returnItemPrice(itemText)
            createItemArray(item)
        }
    }
    
    func createItemArray(item: Item) {
        let quantity = item.quantity
        if quantity > 1 {
            item.price = (item.price/Double(quantity))
            item.quantity = 1
            for _ in 1...quantity {
                itemArray.append(item)
            }
        } else {
            itemArray.append(item)
        }
    }
    
    func saveItemArray() {
        itemStore.setItem(itemArray, forKey: itemBillID)
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
        var quantity = 0
        if NSString(string: int).integerValue == 0 {
            quantity = NSString(string: int).integerValue
        }
        return quantity
    }
    
    func returnItemPrice(itemText: String) -> Double {
        let removedCommas = itemText.stringByReplacingOccurrencesOfString(",", withString: ".")
        let words = removedCommas.characters.split{$0 == " "}.map(String.init)
        var double = String()
        var price: Double = 0.0
        
        for number in words {
            if number.containsADouble {
                double = number
                price = priceFromString(double)
            }
        }
        return price
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
