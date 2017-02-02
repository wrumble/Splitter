//
//  SplitterCarouselItemTableView.swift
//  Splitter
//
//  Created by Wayne Rumble on 24/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class SplitterCarouselItemTableView: UITableView {
    
    var splitter: BillSplitter?
    
    required init(frame: CGRect, style: UITableViewStyle, splitter: BillSplitter) {
        super.init(frame: frame, style: style)
        self.splitter = splitter
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        let tableViewBackground = UIImageView(image: UIImage(data: splitter?.image as! Data, scale:1.0))
        tableViewBackground.contentMode = .scaleAspectFit
        tableViewBackground.frame = self.frame
        
        self.backgroundColor = .clear
        self.backgroundView = tableViewBackground
        self.separatorStyle = .none
    }
}
