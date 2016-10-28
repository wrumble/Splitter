//
//  ViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 04/10/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit

class MyBillsViewController: UIViewController {
    
    @IBOutlet var newBillButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func newBillsButtonWasPressed() {
        self.performSegueWithIdentifier("segueToNewBill", sender: self)
    }

}

