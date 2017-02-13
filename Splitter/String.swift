//
//  StringWidthHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 07/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation

//Returns the width of the String to allow for resizing labels. 
extension String {
    
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
}
