//
//  TextField.swift
//  Splitter
//
//  Created by Wayne Rumble on 09/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class CheckTextField {
    
    func email(sender: UITextField) -> Bool {
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)
        
        if emailTest.evaluate(with: sender.text) == false {
            sender.becomeFirstResponder()
            return false
        }
        return true
    }
    
    func postCode(sender: UITextField) -> Bool {
        let postCodeReg = "^([Gg][Ii][Rr] {0,}0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([AZa-z][0-9][A-Za-z])|([A-Za-‌​z][A-Ha-hJ-Yj-y]][0-9]?[A-Za-z])))) {0,}[0-9][A-Za-z]{2})$"
        let postCodeTest = NSPredicate(format: "SELF MATCHES %@", postCodeReg)
        
        if postCodeTest.evaluate(with: sender.text) == false {
            sender.becomeFirstResponder()
            return false
        }
        return true
    }
}
