//
//  AlertViewHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 09/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class AlertHelper {
    
// MARK: Create warning alert
    func warning(title: String, message: String, exit: Bool) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction: UIAlertAction!
        
        // Exit app if exit variable id true
        if exit {
            
            okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                
                Splitter.exit(0)
            })
            
        // Dismiss alert without action
        } else {
            okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        }
        alert.addAction(okAction)
        
        return alert
    }
}
