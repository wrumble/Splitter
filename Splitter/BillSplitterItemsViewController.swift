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
    var clientTokenizationKey = "sandbox_tyvpfjk9_8vk3dmrv6cjbjp28"
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.navigationItem.title = "\(splitter.name!)"
        self.navigationItem.hidesBackButton = true
        
        splitterItems = splitter.items?.allObjects as! [Item]
        splitterItems.sort { $0.name! < $1.name! }
        emailLabel.text = splitter.email
        totalLabel.text = "Total price £\(splitter.total)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToSplitterPayment" {
            let destinationVC = segue.destination as! SplitterPaymentViewController
            
            destinationVC.total = splitter.total
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if splitterItems.count > 0 {
            return splitterItems.count
        } else {
            TableViewHelper.EmptyMessage("\(splitter.name!) has no items to pay for.\nGo back to assign some items to their name.", tableView: tableView)
            return 0
        }    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ItemCell = tableView.dequeueReusableCell(withIdentifier: "SplitterItemCell") as! ItemCell
        let item = splitterItems[indexPath.row]
        let count = item.billSplitters?.count
        if count! > 1 {
            cell.name!.text = "\(item.name!) split \(count!) ways"
            cell.price!.text = "£\(Double(item.price)/Double(count!))"
        } else {
            cell.name!.text = item.name!
            cell.price!.text = "£\(item.price)"
        }
        
        return cell
    }
}




