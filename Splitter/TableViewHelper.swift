//
//  TableViewHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 23/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class TableViewHelper {
    
    class func EmptyMessage(_ message:String, tableView: UITableView) {
        let messageLabel = UILabel(frame: CGRect(x: 0,y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel;
    }
}
