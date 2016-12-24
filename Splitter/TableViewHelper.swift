//
//  TableViewHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 23/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class TableViewHelper {
    
    class func EmptyMessage(message:String, tableView: UITableView) {
        let messageLabel = UILabel(frame: CGRectMake(0,0, tableView.bounds.size.width, tableView.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .Center;
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel;
    }
}
