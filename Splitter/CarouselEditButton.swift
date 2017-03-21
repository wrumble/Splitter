//
//  SplitterCarouselItemButton.swift
//  Splitter
//
//  Created by Wayne Rumble on 24/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class CarouselEditButton: UIButton {
    
    var addsItem: Bool?

    required override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//Format Buttons View
    func setupView() {
        
        self.backgroundColor = .clear
        self.setImage(UIImage(named: "editIconBlack"), for: .normal)
    }
}
