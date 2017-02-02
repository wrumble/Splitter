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
        
        let width = Int(contentView.bounds.width)
        let height = Int(contentView.bounds.height)

        view = UIView(frame: CGRect(x: 0, y: 2, width: width, height: height - 4 ))
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        let viewHeight = Int(view.bounds.height)
        let viewWidth = Int(view.bounds.width)
        
        price = UILabel(frame: CGRect(x: viewWidth - 85, y: 0, width: 85, height: viewHeight))
        price.font = UIFont.systemFont(ofSize: 15.0)
        price.textAlignment = .left
        
        name = UILabel(frame: CGRect(x: 5, y: 0, width: width, height: viewHeight))
        name.font = UIFont.systemFont(ofSize: 15.0)
        name.numberOfLines = 0
        
        view.addSubview(name)
        view.addSubview(price)
        
        contentView.addSubview(view)
    }
}
