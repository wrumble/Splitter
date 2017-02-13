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
import NVActivityIndicatorView

class SplitterPaymentViewController: UIViewController, CardIOPaymentViewControllerDelegate, NVActivityIndicatorViewable {
    
    let manager = AFHTTPSessionManager()
    
    var total = Double()
    var stripeCard: STPCardParams!
    var expMonth: UInt!
    var expYear: UInt!
    var requestIP: String!
    var stripeAccountID = String()
    var splitter: BillSplitter!
    var bill: NSManagedObject!
    
    @IBOutlet var cardNumberTextField: UITextField!
    @IBOutlet var cardExpiryTextField: UITextField!
    @IBOutlet var cardCVVTextField: UITextField!
    @IBOutlet var payButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAccountID()
        CardIOUtilities.preload()
        
        payButton.setTitle("Pay \(total.asLocalCurrency)", for: UIControlState())
        
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
        
        startAnimating()
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
                self.splitterHasPaid()
            } catch {
                print("Serialising new account json object went wrong.")
            }
        }, failure: { (operation, error) -> Void in
            self.handleError(error as NSError)
        })
    }
    
    func splitterHasPaid() {
        let managedContext = bill.managedObjectContext
        splitter.setValue(true, forKey: "hasPaid")
        
        do {
            try managedContext!.save()
        }
        catch let error as NSError {
            print("Core Data save failed: \(error)")
        }
        stopAnimating()
        handleSuccess()
    }
    
    func handleSuccess() {
        let message = "You succesfully paid \(splitter.total.asLocalCurrency) to \(getMainSplitterName())'s bank account"
        let alert = UIAlertController(title: "Success!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            self.performSegue(withIdentifier: "segueToBillSplitters", sender: self)
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToBillSplitters" {
            
            let allBillSplitters = getAllSplitters()
            
            let destinationVC = segue.destination as! BillSplittersViewController
            let passedBill: NSManagedObject = bill as NSManagedObject
            let billName = (bill as! Bill).name
            
            destinationVC.billName = billName
            destinationVC.bill = passedBill
            destinationVC.allBillSplitters = allBillSplitters
        }
    }
    
    func getAllSplitters() -> [BillSplitter] {
        var allBillSplitters = [BillSplitter]()
        
        let managedContext = bill.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BillSplitter")
        let predicate = NSPredicate(format: "ANY bills == %@", bill)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            allBillSplitters = results as! [BillSplitter]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return allBillSplitters
    }
    
    func getMainSplitterName() -> String {
        var name = String()
        getAllSplitters().forEach { splitter in
            if splitter.isMainBillSplitter { name = splitter.name! }
        }
        
        return name
    }
}
