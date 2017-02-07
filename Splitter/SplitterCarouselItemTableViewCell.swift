//
//  carouselTableViewCell.swift
//  Splitter
//
//  Created by Wayne Rumble on 22/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class SplitterCarouselItemTableViewCell: UITableViewCell {
    
    var name: UILabel!
    var price: UILabel!
    var view: UIView!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "splitterCarouselItemTableViewCell")
        
        self.setupViews()
    }
    
    func setupViews() {
        
        let width = Int(UIScreen.main.bounds.width * 0.88)
        let height = Int(self.bounds.height)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.frame = CGRect(x: 0, y: 0, width: width, height: 45)
        
        view = UIView(frame: CGRect(x: 0, y: 2, width: width, height: height - 4 ))
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        price = UILabel()
        price.font = UIFont.systemFont(ofSize: 15.0)
        price.textAlignment = .right
        
        name = UILabel()
        name.font = UIFont.systemFont(ofSize: 15.0)
        name.numberOfLines = 0
        
        view.addSubview(name)
        view.addSubview(price)
        
        contentView.addSubview(view)
    }
}
