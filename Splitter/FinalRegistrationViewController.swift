//
//  FinalRegistrationViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 16/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import AFNetworking
import Stripe
import NVActivityIndicatorView

class FinalRegistrationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NVActivityIndicatorViewable {
    
    var photoID = UIImage()
    var imagePicker: UIImagePickerController!
    var stripeAccountID = String()
    var fileID = String()
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var accountNumberTextField: UITextField!
    @IBOutlet weak var sortCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addTextFieldTargets()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FinalRegistrationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func addTextFieldTargets() {
        accountNumberTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        accountNumberTextField.addTarget(self, action: #selector(checkAccountNumber), for: .editingDidEnd)
        sortCodeTextField.addTarget(self, action: #selector(checkSortCode), for: .editingDidEnd)
        sortCodeTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
    }
    
    func checkSortCode(sender: UITextField) {
        
        let sortCodeReg = "^[0-9]{1,6}$"
        let sortCodeTest = NSPredicate(format: "SELF MATCHES %@", sortCodeReg)
        if sortCodeTest.evaluate(with: sender.text) == false {
            let alert = UIAlertController(title: "Please enter a valid Sort Code", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkAccountNumber(sender: UITextField) {
        let accountNumberReg = "^[0-9]{1,8}$"
        let accountNumberTest = NSPredicate(format: "SELF MATCHES %@", accountNumberReg)
        if accountNumberTest.evaluate(with: sender.text) == false {
            let alert = UIAlertController(title: "Please enter a valid Account Number", message: "If your account number is 7 digits long please add a 0 to the beginning.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkFields(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard
            let accountNumber = accountNumberTextField.text, !accountNumber.isEmpty,
            let sortCode = sortCodeTextField.text, !sortCode.isEmpty
            
            else { return }
        
        createTakePhotoButton()
    }
    
    func createTakePhotoButton() {
        let width = UIScreen.main.bounds.width
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        button.backgroundColor = UIColor.black
        let title = NSAttributedString(string: "Take Photo", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(takePhotoButtonWasPressed), for: .touchUpInside)
        bottomView.addSubview(button)
    }
    
    func createRegisterButton() {
        let width = UIScreen.main.bounds.width
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        button.backgroundColor = UIColor.black
        let title = NSAttributedString(string: "Register", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(registerButtonWasTapped), for: .touchUpInside)
        bottomView.addSubview(button)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addExternalAccount() {
        let manager = AFHTTPSessionManager()
        let URL = "https://splitterstripeservertest.herokuapp.com/account/external_account"
        let params = [
            "stripe_account": stripeAccountID,
            "account_number": accountNumberTextField.text!,
            "sort_code": sortCodeTextField.text!] as [String : Any]
        
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
    
    func uploadPhotoID() {
        let URL = "https://splitterstripeservertest.herokuapp.com/account/id"
        let imageData = UIImageJPEGRepresentation(photoID, 0.5)
        let params = ["stripe_account": stripeAccountID,
                      "purpose": "identity_document"] as [String : Any]
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.post(URL, parameters: params, constructingBodyWith: { (formData: AFMultipartFormData!) -> Void in
            formData.appendPart(withFileData: imageData!, name: "file", fileName: "photoID.jpg", mimeType: "image/jpeg")
        }, success: {(_ task: URLSessionDataTask, _ responseObject: Any) -> Void in
            do {
                let response = try JSONSerialization.jsonObject(with: responseObject as! Data, options: .mutableContainers) as? [String: Any]
                self.fileID = response?["id"] as! String
                self.stopAnimating()
            } catch {
                print("Serialising account id json object went wrong.")
            }
        }, failure: { (operation, error) -> Void in
            self.handleError(error as NSError)
            self.stopAnimating()
        })
    }
    
    func savePhotoIDToAccount() {
        let URL = "https://splitterstripeservertest.herokuapp.com/account/id/save"
        let params = ["stripe_account": stripeAccountID,
                      "file_id": fileID] as [String : Any]
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(URL, parameters: params, progress: nil, success: {(_ task: URLSessionDataTask, _ responseObject: Any) -> Void in
            do {
                _ = try JSONSerialization.jsonObject(with: responseObject as! Data, options: .mutableContainers) as? [String: Any]
                self.stopAnimating()
            } catch {
                print("Serialising account with verification id json object went wrong.")
            }
        }, failure: { (operation, error) -> Void in
            self.handleError(error as NSError)
            self.stopAnimating()
        })
    }
    
    func handleError(_ error: NSError) {
        let alert = UIAlertController(title: "Please Try Again", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func takePhotoButtonWasPressed(_sender: UIButton) {
        
        addExternalAccount()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        present(imagePicker, animated: true, completion: nil)
        createRegisterButton()
        createAgreementTextView()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        self.photoID = image
        uploadPhotoID()
        picker.dismiss(animated: true, completion: nil)
        startAnimating()
    }
    
    func createAgreementTextView() {
        
        let width = bottomView.frame.width
        let height = bottomView.frame.height
        let agreementTextView: UITextView = UITextView (frame:CGRect(x: 0, y: 50, width: width, height: height-50))
        agreementTextView.backgroundColor = UIColor.black
        agreementTextView.isScrollEnabled = true
        agreementTextView.isUserInteractionEnabled = true
        agreementTextView.isEditable = false
        agreementTextView.dataDetectorTypes = .link
        
        let text = NSMutableAttributedString(string: "By Tapping Register you agree that Payment processing services for you on Splitter are provided by Stripe and are subject to the Stripe Connected Account Agreement, which includes the Stripe Terms of Service. By agreeing to these terms or continuing to operate as a user on Splitter, you agree to be bound by the Stripe Services Agreement, as the same may be modified by Stripe from time to time. As a condition of Splitter enabling payment processing services through Stripe, you agree to provide Splitter accurate and complete information about you and your business, and you authorize Splitter to share it and transaction information related to your use of the payment processing services provided by Stripe.")
        text.addAttribute(NSLinkAttributeName, value: "https://stripe.com/gb/connect-account/legal", range: NSRange(location: 128, length: 35))
        text.addAttribute(NSLinkAttributeName, value: "https://stripe.com/gb/legal", range: NSRange(location: 183, length: 24))
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, text.length))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        text.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: text.length))
        
        agreementTextView.attributedText = text
        bottomView.addSubview(agreementTextView)
    }
    
    func registerButtonWasTapped() {
        startAnimating()
        savePhotoIDToAccount()
        performSegue(withIdentifier: "segueToMyBillsViewController", sender: self)
    }
}
