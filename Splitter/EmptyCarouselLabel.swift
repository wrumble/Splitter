//
//  EmptyCarouselLabel.swift
//  Splitter
//
//  Created by Wayne Rumble on 14/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class EmptyCarouselLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {

        self.text = "You have no bills to split yet. Tap the plus icon to start splitting a new bill."
        self.textAlignment = .center
        self.numberOfLines = 0
    }
}
