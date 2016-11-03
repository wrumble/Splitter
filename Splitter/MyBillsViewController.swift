//
//  ViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 04/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class MyBillsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var allBills: [Bill]?
    
    @IBOutlet var newBillButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // (allBills?.count)!
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: BillCell = tableView.dequeueReusableCellWithIdentifier("billCell") as! BillCell
        let bill = allBills![indexPath.row]
        cell.name.text = bill.name
        cell.date.text = bill.date
        cell.total!.text = "£\(bill.total)"
        return cell
    }
    
    @IBAction func newBillsButtonWasPressed() {
        self.performSegueWithIdentifier("segueToNewBill", sender: self)
    }

}

