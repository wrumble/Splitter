//
//  StringWidthHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 07/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation

extension String {
    
//removes excess new lines and space from the ends of words or sentences
    func trim() -> String {
        
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
//Returns the width of the String to allow for resizing labels.
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height )
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
    
//Returns true if the string contains a Double
    var containsADouble: Bool {
        
        return range(of: "[0-9]{1,}.[0-9]{1,}", options: .regularExpression) != nil
    }

//Returns true if the string is a word.
    var isaWord: Bool {
        
        return range(of: "^[a-zA-Z]+$", options: .regularExpression) != nil
    }
    
//Returns the price from a string containing a double
    mutating func priceFromStringWithDouble() -> Double {
        
        //String extension below
        self.removeCharsFromString()
        
        let index = self.characters.count - 2
        
        self.insert(".", at: self.characters.index(self.startIndex, offsetBy: index))
            
        let price = NumberFormatter().number(from: self)?.doubleValue
        
        return price!
    }
    
//Leaves only numbers in the string
    mutating func removeCharsFromString() {
        
            let okayChars : Set<Character> = Set("0123456789".characters)
            self = String(self.characters.filter {okayChars.contains($0) })
    }
    
//Replaces any 'S' or 's' in a string with that contains a double with a five
    mutating func replaceWhereFiveShouldBe() {
        
        self = self.replacingOccurrences(of: "S", with: "5", options: .literal, range: nil)
        self = self.replacingOccurrences(of: "s", with: "5", options: .literal, range: nil)
    }
    
//Replaces any 'l', 'i' or 'I' in a string with that contains a double with a One
    mutating func replaceWhereOneShouldBe() {
        
        self = self.replacingOccurrences(of: "l", with: "1", options: .literal, range: nil)
        self = self.replacingOccurrences(of: "i", with: "1", options: .literal, range: nil)
        self = self.replacingOccurrences(of: "I", with: "1", options: .literal, range: nil)
    }
    
    mutating func replaceWhereZeroShouldBe() {
        
        self = self.replacingOccurrences(of: "o", with: "0", options: .literal, range: nil)
        self = self.replacingOccurrences(of: "O", with: "0", options: .literal, range: nil)
    }
}
