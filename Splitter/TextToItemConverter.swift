//
//  TextToItemConverter.swift
//  Splitter
//
//  Created by Wayne Rumble on 03/11/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

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

class TextToItemConverter {
    
    var bill: NSManagedObject!
    
    func seperateTextToLines(receiptText: String) {
        let newlineChars = NSCharacterSet.newlineCharacterSet()
        let lines = receiptText.utf16.split { newlineChars.characterIsMember($0) }.flatMap(String.init)
        for line in lines { createItems(line) }
        setBillTotal()
    }
    
    func createItems(itemText: String) {
        if itemText.characters.count > 5 {
            
            let managedContext = bill.managedObjectContext
            let entity =  NSEntityDescription.entityForName("Item", inManagedObjectContext: managedContext!)
            let newItem = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            
            newItem.setValue(returnItemName(itemText), forKey: "name")
            newItem.setValue(returnItemQuantity(itemText), forKey: "quantity")
            newItem.setValue(returnItemPrice(itemText), forKey: "price")
            
            let currentItems = bill.mutableSetValueForKey("items")
            currentItems.addObject(newItem)
            do {
                try managedContext!.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    func setBillTotal() {
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Item")
        let predicate = NSPredicate(format: "bill == %@", bill)
        fetchRequest.predicate = predicate
        
        var items = [Item]()
        do {
            let results =
                try managedContext!.executeFetchRequest(fetchRequest)
            items = results as! [Item]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        var sum = Int(0.0)
        for item in items {
            sum += Int(item.price)
        }
        
        bill.setValue(sum, forKey: "total")
        do {
            try managedContext!.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
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
        var quantity = 1
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

