//
//  NextButton.swift
//  Splitter
//
//  Created by Wayne Rumble on 09/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class NextButton: UIButton {
    
    required override init(frame: CGRect) {
        
        super.init(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 50))
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        let nextButtonTitle = "Next"
        self.backgroundColor = UIColor(netHex: 0x000010)
        let title = NSAttributedString(string: nextButtonTitle, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)])
        self.setAttributedTitle(title, for: .normal)
    }
}
