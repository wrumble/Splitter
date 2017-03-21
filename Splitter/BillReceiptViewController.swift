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
    var pan: UIPanGestureRecognizer!
    var pinch: UIPinchGestureRecognizer!
    
    @IBOutlet weak var billName: UILabel!
    @IBOutlet var receiptImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNameLabel()
        setGestureRecognizers()
        setReceiptImageView()
    }
    
//Format name label
    func setNameLabel() {
        
        billName.text = "\(bill.name!)"
        billName.backgroundColor = UIColor(netHex: 0xe9edef).withAlphaComponent(0.75)
    }
    
//Apply pinch and pan recognisers to receipt image
    func setGestureRecognizers() {
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureDetected))
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGestureDetected))
        
        pan.delegate = self
        pinch.delegate = self
    }
    
//Adds pinch and pan recognisers to image
    func setReceiptImageView() {
    
        receiptImageView.isUserInteractionEnabled = true
        receiptImageView.image = UIImage(data:bill.image as! Data, scale:1.0)
        receiptImageView.addGestureRecognizer(pan)
        receiptImageView.addGestureRecognizer(pinch)
    }
    
//Pass bill to next VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! BillViewController
        
        destinationVC.bill = bill
    }
    
//Go back to Bill View when button pressed
    @IBAction func backButtonWasPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "segueBackToBill", sender: self)
    }

//Allow pan movements on image
    func panGestureDetected(_ recognizer: UIPanGestureRecognizer) {
        
        let state: UIGestureRecognizerState = recognizer.state
        
        if state == .began || state == .changed {
            
            let translation: CGPoint = recognizer.translation(in: recognizer.view)
            recognizer.view?.transform = (recognizer.view?.transform.translatedBy(x: translation.x, y: translation.y))!
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        }
    }
    
//Allow pinch movements on image
    func pinchGestureDetected(_ recognizer: UIPinchGestureRecognizer) {
        
        let state: UIGestureRecognizerState = recognizer.state
        
        if state == .began || state == .changed {
            
            let scale: CGFloat = recognizer.scale
            recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: scale, y: scale))!
            recognizer.scale = 1.0
        }
    }
    
//Recognise multiple gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
