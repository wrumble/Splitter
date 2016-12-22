//
//  BillSplitterItemsViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 20/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class BillSplitterItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var splitterItems: [Item]!
    var splitter: BillSplitter!
    var bill: Bill!
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.title = "\(splitter.name!)"
        self.navigationItem.hidesBackButton = true
        
        splitterItems = splitter.items?.allObjects as! [Item]
        splitterItems.sortInPlace { $0.name < $1.name }
        emailLabel.text = splitter.email
        totalLabel.text = "Total price £\(splitter.total!)"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return splitterItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: ItemCell = tableView.dequeueReusableCellWithIdentifier("SplitterItemCell") as! ItemCell
        let item = splitterItems[indexPath.row]
        let count = item.billSplitters?.count
        if count > 1 {
            cell.name!.text = "\(item.name!) split \(count!) ways"
            cell.price!.text = "£\(Double(item.price!)/Double(count!))"
        } else {
            cell.name!.text = item.name!
            cell.price!.text = "£\(item.price!)"
        }
        
        return cell
    }
}
