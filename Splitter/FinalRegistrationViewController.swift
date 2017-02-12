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
import CoreData

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
    
//MARK: dismissKeyboard
//Hides keyboard when tapping anywhere other than a textfield.
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
// MARK: setTextFieldTags
//Add tags to textfields with consistencies that can be checked.
    func setTextFieldTags() {
        accountNumberTextField.tag = 0
        sortCodeTextField.tag = 1
    }
// MARK: addTextFieldTargets
//Assign target functions to any textFields that need them.
    func addTextFieldTargets() {
        accountNumberTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        sortCodeTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        accountNumberTextField.addTarget(self, action: #selector(checkField), for: .editingDidEnd)
        sortCodeTextField.addTarget(self, action: #selector(checkField), for: .editingDidEnd)
    }
    
// MARK: checkField
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
    
// MARK: isEmptyField
//If textFields arent empty show the Next button.
    func isEmptyField(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard
            let accountNumber = accountNumberTextField.text, !accountNumber.isEmpty,
            let sortCode = sortCodeTextField.text, !sortCode.isEmpty
            
            else { return }
        
        createTakePhotoButton()
    }
    
//MARK: createTakePhotoButton
//Show Take Photo button once all fields contain text.
    func createTakePhotoButton() {
        let button = RegistrationButton(title: "Take Photo")
        button.addTarget(self, action: #selector(takePhotoButtonWasPressed), for: .touchUpInside)
        bottomView.addSubview(button)
    }
    
//MARK: takePhotoButtonWasPressed
//Starts a custom activity indicator(NVActivityIndicatorView) then calls api request to add external account details to Stripe account made in previous view controller.
    @IBAction func takePhotoButtonWasPressed(_sender: UIButton) {
        
        addExternalAccount()
    }
    
//MARK: setParams
//Create params to send with api request to Stripe.
    func setParams() -> [String : Any] {
        
        let params = [
            "stripe_account": stripeAccountID,
            "account_number": accountNumberTextField.text!.trim(),
            "sort_code": sortCodeTextField.text!.trim()] as [String : Any]
        
        return params
    }
    
//MARK: addExternalAccount
//Make request to Stripe to create add account details to account made previously.
    func addExternalAccount() {
        HttpRequest().post(params: self.setParams(), URLExtension: "account/external_account",
                     success: { response in
                        
                        self.successfulRequest() },
                     
                     fail: { response in
                        
                        self.failedRequest(response: response as AnyObject)
        })
    }
    
//MARK: successfulRequest
//If api request is successful then save received account id, stop activity indicator and move onto next step in creating account.
    func successfulRequest() {
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
    
//MARK: displayImagePicker
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
    
//MARK: imagePickerController
//Sets the image from the camera or photoLibrary, calls uploadPhotoID function then starts a custom activity indicator(NVActivityIndicatorView).
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        self.photoID = image
        uploadPhotoID()
        picker.dismiss(animated: true, completion: nil)
        startAnimating()
    }
    
//MARK: uploadPhotoID
//Makes api request to upload photoID to Stripe account created earlier.
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
    
//MARK: createRegisterButton
//Show register button once all fields contain text.
    func createRegisterButton() {
        let button = RegistrationButton(title: "Register")
        button.addTarget(self, action: #selector(registerButtonWasPressed), for: .touchUpInside)
        bottomView.addSubview(button)
    }
    
//MARK: registerButtonWasPressed
//Starts a custom activity indicator(NVActivityIndicatorView) then calls api request to upload verification id.
    func registerButtonWasPressed() {
        startAnimating()
        savePhotoIDToAccount()
        performSegue(withIdentifier: "segueToMyBillsViewController", sender: self)
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
    
    func createAgreementTextView() {
        
        let width = bottomView.frame.width
        let height = bottomView.frame.height - 60
        let frame = CGRect(x: 0, y: 60, width: width, height: height)
        let agreementTextView = AgreementTextView(frame: frame, textContainer: nil)

        bottomView.addSubview(agreementTextView)
    }
    
}
