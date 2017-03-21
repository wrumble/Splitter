//
//  carouselItemDateLabel.swift
//  Splitter
//
//  Created by Wayne Rumble on 07/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class CarouselDateLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//Format Labels View
    func setupView() {
        
        self.backgroundColor = .clear
        self.textAlignment = .right
        self.textColor = UIColor(netHex: 0x000010)
        self.font = self.font.withSize(15)
    }
}
