//
//  TextToItemConverter.swift
//  Splitter
//
//  Created by Wayne Rumble on 03/11/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class TextToItemConverter {
    
    var bill: NSManagedObject!
    var coreDataHelper = CoreDataHelper()
    
    func seperateTextToLines(_ receiptText: String) {
        
        let newlineChars = CharacterSet.newlines
        let lines = receiptText.utf16.split { newlineChars.contains(UnicodeScalar($0)!) }.flatMap(String.init)
        
        for line in lines { saveItems(line) }
    }
    
//Save each item line to the bill if it is above 5 characters long
    func saveItems(_ itemText: String) {
        
        //Each item line on the receipt will have the price 0.01 and at least a word so minnimum line length can be minimum 5 characters, maybe even 6
        if itemText.characters.count > 5 {
            
            coreDataHelper.saveItem(bill, values: createItemValues(itemText))
        }
    }
    
//Create has of item values to be passed to the coredata helper.
    func createItemValues(_ itemText: String) -> [String: Any] {
        
        return ["quantity": returnItemQuantity(itemText),
                "name": returnItemName(itemText),
                "price": returnItemPrice(itemText),
                "id": (bill as! Bill).id!] as [String: Any]
    }
    
//Returns just the integer value form the string
    func returnItemQuantity(_ itemText: String) -> Int {
        
        var quantity = 1
        
        if NSString(string: itemText).integerValue > 1 {
            
            quantity = NSString(string: itemText).integerValue
        }
        
        return quantity
    }
    
//Removes any numbers or symbols from the string
    func returnItemName(_ itemText: String) -> String {
        
        let words = itemText.characters.split{$0 == " "}.map(String.init)
        var name = [String]()
        
        for word in words {
            
            //See string extensions
            if word.isaWord {
                
                name.append(word)
            }
        }
        
        return name.joined(separator: " ")
    }
    
    
//Returns just the Double value contained within the string
    func returnItemPrice(_ itemText: String) -> Double {
        
        //Replace any commas in text to avoid confusion when finding a double
        let removedCommas = itemText.replacingOccurrences(of: ",", with: ".")
        let words = removedCommas.characters.split{$0 == " "}.map(String.init)
        var priceString = words.last!
        var price: Double = 0.0
        print(priceString)
        priceString.replaceWhereFiveShouldBe()
        priceString.replaceWhereOneShouldBe()
        
        price = priceString.priceFromStringWithDouble()
        
        return price
    }
}

