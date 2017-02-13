//
//  TableViewHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 23/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit


//Adds a label describing a lack of entries in the table view to be displayed.
class TableViewHelper {
    
    class func EmptyMessage(_ message: String, tableView: UITableView) {
        let messageLabel = UILabel(frame: CGRect(x: 5,y: 0, width: tableView.bounds.size.width - 10, height: 30))
        
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        
        let messageView = UIView(frame: CGRect(x: 0,y: 0, width: tableView.bounds.size.width, height: messageLabel.bounds.height))
        messageView.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.3)
        messageView.center = tableView.center
        messageView.addSubview(messageLabel)
        
        tableView.backgroundView?.addSubview(messageView)
    }
}
