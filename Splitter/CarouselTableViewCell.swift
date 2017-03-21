//
//  carouselTableViewCell.swift
//  Splitter
//
//  Created by Wayne Rumble on 22/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class CarouselTableViewCell: UITableViewCell {
    
    var width: Int?
    var height: Int?
    
    var name: UILabel!
    var price: UILabel!
    var view: UIView!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "carouselTableViewCell")
        
        self.setVariables()
        self.setupViews()
    }
    
//Get height of device screen and the devices width tims 0.88 which is the same as its tableview and carousel view
    func setVariables() {
        
        width = Int(UIScreen.main.bounds.width * 0.88)
        height = Int(self.bounds.height)
    }
    
//Create and apply views to the cell.
    func setupViews() {
        
        setPriceLabel()
        setNameLabel()
        setLabelView()
        setCellView()
        
        contentView.addSubview(view)
    }
    
//Format cell
    func setCellView() {
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.frame = CGRect(x: 0, y: 0, width: width!, height: 45)
    }

//Create and format the price label
    func setPriceLabel() {
        
        price = UILabel()
        price.font = UIFont.systemFont(ofSize: 15.0)
        price.textAlignment = .right
    }
    
//Create and format the name label
    func setNameLabel() {
        
        name = UILabel()
        name.font = UIFont.systemFont(ofSize: 15.0)
        name.numberOfLines = 0
    }
    
//Create and format the view the labels fit into
    func setLabelView() {
        
        view = UIView(frame: CGRect(x: 0, y: 2, width: width!, height: height! - 4 ))
        
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.addSubview(name)
        view.addSubview(price)
    }
}
