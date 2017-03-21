//
//  BillCarouselItemTableView.swift
//  Splitter
//
//  Created by Wayne Rumble on 01/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class CarouselBillTableView: UITableView {
        
    required init(frame: CGRect, style: UITableViewStyle, bill: Bill) {
        super.init(frame: frame, style: style)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//FormatTableView
    func setupView() {
        
        self.backgroundColor = .clear
        self.separatorStyle = .none
    }
}
