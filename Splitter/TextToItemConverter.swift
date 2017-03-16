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
    
    func seperateTextToLines(_ receiptText: String) {
        let newlineChars = CharacterSet.newlines
        let lines = receiptText.utf16.split { newlineChars.contains(UnicodeScalar($0)!) }.flatMap(String.init)
        for line in lines { createItems(line) }
    }
    
    func createItems(_ itemText: String) {
        
        if itemText.characters.count > 5 {
            
            let managedContext = bill.managedObjectContext
            let entity =  NSEntityDescription.entity(forEntityName: "Item", in: managedContext!)
            let currentItems = bill.mutableSetValue(forKey: "items")
            let quantity = returnItemQuantity(itemText)
            let date = Date() as NSDate
            
            for _ in 1...quantity {
                
                let newItem = NSManagedObject(entity: entity!, insertInto: managedContext)
                
                newItem.setValue(quantity, forKey: "quantity")
                newItem.setValue(returnItemName(itemText), forKey: "name")
                newItem.setValue(returnItemPrice(itemText), forKey: "price")
                newItem.setValue(date, forKey: "creationDateTime")
                newItem.setValue((bill as! Bill).id, forKey: "id")
                currentItems.add(newItem)
            }
            
            do {
                try managedContext!.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    func returnItemName(_ itemText: String) -> String {
        let words = itemText.characters.split{$0 == " "}.map(String.init)
        var name = [String]()
        
        for word in words {
            if word.isaWord {
                name.append(word)
            }
        }
        return name.joined(separator: " ")
    }
    
    func returnItemQuantity(_ itemText: String) -> Int {
        
        var quantity = 1
        if NSString(string: itemText).integerValue > 1 {
            
            quantity = NSString(string: itemText).integerValue
        }
        
        return quantity
    }
    
    func returnItemPrice(_ itemText: String) -> Double {
        
        let removedCommas = itemText.replacingOccurrences(of: ",", with: ".")
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
    
    func removeCharsFromString(_ text: String) -> String {
        
        let okayChars : Set<Character> =
            Set("0123456789".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    func priceFromString(_ string: String) -> Double {
        
        var newString = removeCharsFromString(string)
        let index = newString.characters.count - 2
        newString.insert(".", at: newString.characters.index(newString.startIndex, offsetBy: index))
        let price = (NumberFormatter().number(from: newString)?.doubleValue)!
        
        return price
    }
}

