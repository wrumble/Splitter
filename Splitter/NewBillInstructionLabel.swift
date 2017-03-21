//
//  NewBillInstructionLabel.swift
//  Splitter
//
//  Created by Wayne Rumble on 15/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class NewBillInstructionLabel: UILabel {
    
    let height = 200
    let width = Int(UIScreen.main.bounds.width)
    
    override init(frame: CGRect) {
        
        let frame = CGRect(x:5, y:0, width: width - 5, height: height)
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        self.textColor = UIColor(netHex: 0x000010)
        self.numberOfLines = 0
        self.textAlignment = .center
        self.text = labelText()
    }
    
    func labelText() -> String {
        
        return "Once you have taken a clear, straight photo of your receipt. Crop the image so it contains only a list of each items name, price and quantity. You do not need to include the bill total in the cropped image."
    }
}
