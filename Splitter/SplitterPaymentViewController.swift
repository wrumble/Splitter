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
import CoreData

class SplitterPaymentViewController: UIViewController, CardIOPaymentViewControllerDelegate {
    
    let manager = AFHTTPSessionManager()
    
    var total = Double()
    var stripeCard: STPCardParams!
    var expMonth: UInt!
    var expYear: UInt!
    var requestIP: String!
    var stripeAccountID = String()
    
    @IBOutlet var cardNumberTextField: UITextField!
    @IBOutlet var cardExpiryTextField: UITextField!
    @IBOutlet var cardCVVTextField: UITextField!
    @IBOutlet var payButton: UIButton!
    @IBOutlet var loginWithStripeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAccountID()
        CardIOUtilities.preload()
        
        payButton.setTitle("Pay £\(total)", for: UIControlState())
        
        cardNumberTextField!.addTarget(self, action: #selector(SplitterPaymentViewController.cardNumberTextFieldWasTapped(_:)), for: UIControlEvents.touchDown)
        
    }
    
    func getAccountID() {
        var allBillSplitters = [BillSplitter]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BillSplitter")
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            allBillSplitters = results as! [BillSplitter]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        allBillSplitters.forEach { billSplitter in
            if billSplitter.isMainBillSplitter {
                stripeAccountID = billSplitter.accountID!
            }
        }
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
            self.chargeBillSplittersCard(token!)
        })
    }

    func handleError(_ error: NSError) {
        let alert = UIAlertController(title: "Please Try Again", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func chargeBillSplittersCard(_ token: STPToken) {
        
        let URL = "https://splitterstripeservertest.herokuapp.com/charge"
        let params = ["source": token.tokenId,
                      "stripe_accountID": stripeAccountID,
                      "amount": total,
                      "currency": "gbp",
                      "description": "Splitter Payment"] as [String : Any]
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(URL, parameters: params, progress: nil, success: {(_ task: URLSessionDataTask, _ responseObject: Any) -> Void in
            do {
                _ = try JSONSerialization.jsonObject(with: responseObject as! Data, options: .mutableContainers) as? [String: Any]
            } catch {
                print("Serialising new account json object went wrong.")
            }
        }, failure: { (operation, error) -> Void in
            self.handleError(error as NSError)
        })
    }
}
