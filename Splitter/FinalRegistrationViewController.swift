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
        
        accountNumberTextField.text = "12345678"
        sortCodeTextField.text = "123456"

        setTextFieldTags()
        addTextFieldTargets()
        
        // Hides keyboard when tapping anywhere other than a textfield.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FinalRegistrationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
//Hides keyboard when tapping anywhere other than a textfield.
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
// MARK: Filling out and checking textField
//Add tags to textfields with consistencies that can be checked.
    func setTextFieldTags() {
        accountNumberTextField.tag = 0
        sortCodeTextField.tag = 1
    }
//Assign target functions to any textFields that need them.
    func addTextFieldTargets() {
        accountNumberTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        sortCodeTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        accountNumberTextField.addTarget(self, action: #selector(checkField), for: .editingDidEnd)
        sortCodeTextField.addTarget(self, action: #selector(checkField), for: .editingDidEnd)
    }
    
//Check any fields if they contain a set format.
    func checkField(sender: UITextField) {
        
        var title:  String!
        
        // If textField is account number then check it and present alertView if incorrect format entered.
        if sender.tag == 0 {
            
            if !CheckTextField().accountNumber(sender: sender) {
                title = "Please enter a valid Account Number"
                let message = "If your account number is 7 digits long please add a 0 to the beginning."
                let alert = AlertHelper().warning(title: title, message: message, exit: false)
                self.present(alert, animated: true, completion: nil)
            }
            // If textField is sort code then check it and present alertView if incorrect format entered.
        } else if sender.tag == 1 {
            
            if !CheckTextField().sortCode(sender: sender) {
                title = "Please enter a valid Sort Code"
                let alert = AlertHelper().warning(title: title, message: "", exit: false)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
//If textFields arent empty show the Next button.
    func isEmptyField(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard
            let accountNumber = accountNumberTextField.text, !accountNumber.isEmpty,
            let sortCode = sortCodeTextField.text, !sortCode.isEmpty
            
            else { return }
        
        createTakePhotoButton()
    }
    
//Show Take Photo button once all fields contain text.
    func createTakePhotoButton() {
        let button = RegistrationButton(title: "Take Photo")
        button.addTarget(self, action: #selector(takePhotoButtonWasPressed), for: .touchUpInside)
        bottomView.addSubview(button)
    }
    
//MARK: Uploading external account details to Connect account.
//Starts a custom activity indicator(NVActivityIndicatorView) then calls api request to add external account details to Stripe account made in previous view controller.
    @IBAction func takePhotoButtonWasPressed(_sender: UIButton) {
        
        addExternalAccount()
    }
    
//Create params to send with api request to Stripe.
    func setAccountParams() -> [String : Any] {
        
        return [
            "stripe_account": stripeAccountID,
            "account_number": accountNumberTextField.text!.trim(),
            "sort_code": sortCodeTextField.text!.trim()] as [String : Any]
    }
    
//Make request to Stripe to create add account details to account made previously.
    func addExternalAccount() {
        HttpRequest().post(params: self.setAccountParams(), URLExtension: "account/external_account",
                     success: { response in
                        
                        self.successfulAccountRequest() },
                     
                     fail: { response in
                        
                        self.failedRequest(response: response as AnyObject)
        })
    }
    
//If api request is successful then save received account id, stop activity indicator and move onto next step in creating account.
    func successfulAccountRequest() {
        present(self.displayImagePicker(), animated: true, completion: nil)
        createRegisterButton()
        createAgreementTextView()
    }
    
//MARK: failedRequest
//If api request fails, then create an alert view with reason why.
    func failedRequest(response: AnyObject) {
        self.stopAnimating()
        let alert = HttpRequest().handleError(response["failed"] as! NSError)
        self.present(alert, animated: true, completion: nil)
    }
    
//MARK: Taking photoID picture.
//Displays camera to take photo of users verification id, or photoLibrary if using simulator.
    func displayImagePicker() -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        return imagePicker
    }
    
//Sets the image from the camera or photoLibrary, calls uploadPhotoID function then starts a custom activity indicator(NVActivityIndicatorView).
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        self.photoID = image
        uploadPhotoID()
        picker.dismiss(animated: true, completion: nil)
        startAnimating()
    }
    
//MARK: Uploading photoID Image to connect account.
//Makes api request to upload photoID to Stripe account created earlier.
    func uploadPhotoID() {
        
        HttpRequest().postWithImageData(params: self.setUploadPhotoIDParams(), URLExtension: "account/id", imageData: UIImageJPEGRepresentation(photoID, 0.5)!,
                                        
                           success: { response in
                            
                                    self.successfulUploadRequest(response: response as AnyObject) },
                           
                           fail: { response in
                            
                                    self.failedRequest(response: response as AnyObject)
        })
    }
    
//If api request is successful then save received file id, stop activity indicator.
    func successfulUploadRequest(response: AnyObject) {
        
        self.fileID = response["id"] as! String
        self.stopAnimating()
    }
    
    func setUploadPhotoIDParams() -> [String : Any] {
        
        return ["stripe_account": stripeAccountID,
                "purpose": "identity_document"] as [String : Any]
    }
    
//Show register button once all fields contain text.
    func createRegisterButton() {
        let button = RegistrationButton(title: "Register")
        button.addTarget(self, action: #selector(registerButtonWasPressed), for: .touchUpInside)
        bottomView.addSubview(button)
    }
    
//MARK: Saving photoID to Connect account.
//Starts a custom activity indicator(NVActivityIndicatorView) then calls api request to upload verification id.
    func registerButtonWasPressed() {
        startAnimating()
        savePhotoIDToAccount()
        performSegue(withIdentifier: "segueToMyBillsViewController", sender: self)
    }
    
//Create params to send with api request to Stripe.
    func setPhotoIDParams() -> [String : Any] {
        
        return ["stripe_account": stripeAccountID,
                "file_id": fileID] as [String : Any]
    }
    
//Makes api request to save photoID to Stripe account created earlier.
    func savePhotoIDToAccount() {
        
        HttpRequest().post(params: self.setPhotoIDParams(), URLExtension: "account/id/save",
                           success: { response in
                            
                                    self.stopAnimating() },
                           
                           fail: { response in
                            
                                    self.failedRequest(response: response as AnyObject)
        })
    }

//Adds required agreement text and Stripe T's and C's once photo has been taken.
    func createAgreementTextView() {
        
        let width = bottomView.frame.width
        let height = bottomView.frame.height - 60
        let frame = CGRect(x: 0, y: 60, width: width, height: height)
        let agreementTextView = AgreementTextView(frame: frame, textContainer: nil)

        bottomView.addSubview(agreementTextView)
    }
    
}
