//
//  TextField.swift
//  Splitter
//
//  Created by Wayne Rumble on 09/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class CheckTextField {
    
//MARK: Check email address entry for characters, then '@', then '.' and more characters in that order.
    func email(sender: UITextField) -> Bool {
        
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)
        
        if emailTest.evaluate(with: sender.text) == false {
            sender.becomeFirstResponder()
            return false
        }
        return true
    }
    
//MARK: Check postCode entry for standard formatting. Regex found on government website and tweaked to allow spaces and Caps.
    func postCode(sender: UITextField) -> Bool {
        
        let postCodeReg = "^([Gg][Ii][Rr] {0,}0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([AZa-z][0-9][A-Za-z])|([A-Za-‌​z][A-Ha-hJ-Yj-y]][0-9]?[A-Za-z])))) {0,}[0-9][A-Za-z]{2})$"
        let postCodeTest = NSPredicate(format: "SELF MATCHES %@", postCodeReg)
        
        if postCodeTest.evaluate(with: sender.text) == false {
            sender.becomeFirstResponder()
            return false
        }
        return true
    }

//MARK: Check if account number entry consists of only eight numbers. Some UK account numbers are seven numbers long but should be preceeded with a zero if so. The alert should mention this.
    func accountNumber(sender: UITextField) -> Bool {
        
        let accountNumberReg = "^[0-9]{8,8}$"
        let accountNumberTest = NSPredicate(format: "SELF MATCHES %@", accountNumberReg)
        if accountNumberTest.evaluate(with: sender.text) == false {
            return false
        }
        return true
    }

//MARK: Check if sort code entry consists of only six numbers.
    func sortCode(sender: UITextField) -> Bool {
        
        let sortCodeReg = "^[0-9]{6,6}$"
        let sortCodeTest = NSPredicate(format: "SELF MATCHES %@", sortCodeReg)
        if sortCodeTest.evaluate(with: sender.text) == false {
            return false
        }
        return true
    }
}
