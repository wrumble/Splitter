//
//  SplitterPaymentViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 06/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import Stripe
import AFNetworking

class SplitterPaymentViewController: UIViewController, CardIOPaymentViewControllerDelegate {
    
    var total = Double()
    var stripeCard: STPCardParams!
    
    @IBOutlet var cardNumberTextField: UITextField!
    @IBOutlet var cardExpiryTextField: UITextField!
    @IBOutlet var cardCVVTextField: UITextField!
    @IBOutlet var payButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CardIOUtilities.preload()
        
        payButton.setTitle("Pay £\(total)", for: UIControlState())
        
        cardNumberTextField!.addTarget(self, action: #selector(SplitterPaymentViewController.cardNumberTextFieldWasTapped(_:)), for: UIControlEvents.touchDown)
        
    }
    
    func cardNumberTextFieldWasTapped(_ textField: UITextField) {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        cardIOVC?.useCardIOLogo = true
        cardIOVC?.guideColor = UIColor.darkGray
        present(cardIOVC!, animated: true, completion: nil)
    }
    
    public func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            cardNumberTextField.text = info.cardNumber!
            cardExpiryTextField.text = "\(String(format: "%02d", info.expiryMonth))/\(info.expiryYear%100)"
            cardCVVTextField.text = info.cvv!
        }
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func payButtonWasPressed() {
        stripeCard = STPCardParams()

        let expirationDate = self.cardExpiryTextField.text!.components(separatedBy: "/")
        let expMonth = UInt(expirationDate[0])
        let expYear = UInt(expirationDate[1])
        
        stripeCard.number = self.cardNumberTextField.text
        stripeCard.cvc = self.cardCVVTextField.text
        stripeCard.expMonth = expMonth!
        stripeCard.expYear = expYear!
        
        STPAPIClient.shared().createToken(withCard: stripeCard, completion: { (token, error) -> Void in
            
            if error != nil {
                self.handleError(error! as NSError)
                return
            } 
            
            self.postStripeToken(token!)
        })
    }

    func handleError(_ error: NSError) {
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
        
    }
    
    func postStripeToken(_ token: STPToken) {
        
        let URL = "https://splitterstripeserver.herokuapp.com/charge"
        let params = ["source": token.tokenId,
                      "amount": total] as [String : Any]
        
        let manager = AFHTTPSessionManager()
        manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
            
            if let response = responseObject as? [String: String] {
                UIAlertView(title: response["status"],
                    message: response["message"],
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
            }
            
        }) { (operation, error) -> Void in
            self.handleError(error as NSError)
        }
    }
    
}
