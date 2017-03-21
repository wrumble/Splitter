//
//  NextButton.swift
//  Splitter
//
//  Created by Wayne Rumble on 09/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class RegistrationButton: UIButton {
    
    var buttonTitle: String!
    
    required init(title: String) {
        super.init(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 50))
        
        self.buttonTitle = title
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//Format the buttons appearance
    func setupView() {
        
        self.backgroundColor = UIColor(netHex: 0x000010)
        let title = NSAttributedString(string: buttonTitle, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)])
        self.setAttributedTitle(title, for: .normal)
    }
}
