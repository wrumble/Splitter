//
//  SplitterCarouselItemView.swift
//  Splitter
//
//  Created by Wayne Rumble on 24/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class SplitterCarouselItemView: UIView {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var payButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor(netHex: 0x9ecfe7)
    }
}
