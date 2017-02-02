//
//  BillImageViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 15/12/2016.
//  Copyright © 2016 Wayne Rumble. All rights reserved.
//

import UIKit
import CoreData

class BillReceiptViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var bill: Bill!
    
    @IBOutlet weak var billName: UILabel!
    @IBOutlet var receiptImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        billName.text = "\(bill.name!)"
        billName.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.75)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureDetected))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGestureDetected))
        
        pan.delegate = self
        pinch.delegate = self

        receiptImageView.isUserInteractionEnabled = true
        receiptImageView.image = UIImage(data:bill.image as! Data, scale:1.0)
        receiptImageView.addGestureRecognizer(pan)
        receiptImageView.addGestureRecognizer(pinch)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! BillViewController
        
        destinationVC.bill = bill
        destinationVC.billName = bill.name
    }
    
    @IBAction func backButtonWasPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "segueBackToBill", sender: self)
    }
    
    func panGestureDetected(_ recognizer: UIPanGestureRecognizer) {
        let state: UIGestureRecognizerState = recognizer.state
        if state == .began || state == .changed {
            let translation: CGPoint = recognizer.translation(in: recognizer.view)
            recognizer.view?.transform = (recognizer.view?.transform.translatedBy(x: translation.x, y: translation.y))!
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        }
    }
    
    func pinchGestureDetected(_ recognizer: UIPinchGestureRecognizer) {
        let state: UIGestureRecognizerState = recognizer.state
        if state == .began || state == .changed {
            let scale: CGFloat = recognizer.scale
            recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: scale, y: scale))!
            recognizer.scale = 1.0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
