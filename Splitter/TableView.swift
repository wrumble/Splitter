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
    
    var message: String!
    var tableView: UITableView!
    var messageLabel: UILabel!
    var messageView: UIView!
    
//Creates the message view and label to be displayed in the tableView
    func createEmptyMessage(_ message: String, tableView: UITableView) {
        
        setHelperVariables(message, tableView: tableView)
        setMessageLabel()
        setMessageView()
        setTableView()
    }
    
//Assigns passed variables
    func setHelperVariables(_ message: String, tableView: UITableView) {
        
        self.message = message
        self.tableView = tableView
    }
    
//Creates the message Label
    func setMessageLabel() {
        
        messageLabel = UILabel(frame: CGRect(x: 5,y: 0, width: tableView.bounds.size.width - 10, height: 30))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
    }
    
//Creates the message view
    func setMessageView() {
        
        messageView = UIView(frame: CGRect(x: 0,y: 0, width: tableView.bounds.size.width, height: messageLabel.bounds.height))
        messageView.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.3)
        messageView.center = tableView.center
        messageView.addSubview(messageLabel)
    }
    
//Adds the view to the tableView
    func setTableView() {
        
        tableView.superview?.addSubview(messageView)
    }
}
