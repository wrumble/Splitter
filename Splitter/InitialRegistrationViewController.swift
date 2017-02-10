//
//  StripeAccountSignUpViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 09/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import Stripe
import AFNetworking
import CoreData
import NVActivityIndicatorView
import DeviceKit
import AVFoundation

class InitialRegistrationViewController: UIViewController, UINavigationControllerDelegate, NVActivityIndicatorViewable {
    
    let checkTextField = CheckTextField()
    let request = HttpRequest()
    let alert: AlertHelper! = nil
    
    var quantity = CGFloat(200)
    var stripeAccountID = String()
    var profileImage = UIImageView()
    var profilePhoto: ProfilePhoto!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var addressLine1TextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postCodeTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides keyboard when tapping anywhere other than a textfield.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setTextFieldTags()
        addTextFieldTargets()
    }

//MARK: Start profile photo session.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profilePhoto = ProfilePhoto()
        profilePhoto.startSession()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToFinalRegistrationViewController" {
            
            let destinationVC = segue.destination as! FinalRegistrationViewController
            destinationVC.stripeAccountID = stripeAccountID
        }
    }
    
//MARK: Display a date picker for D.O.B textField.
    @IBAction func datePicker(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
    }
    
//MARK: Format datePicker selection
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dobTextField.text = dateFormatter.string(from: sender.date)
    }
    
//MARK: Take sneaky profile photo after first name has been entered.
    func capturePhoto() {
        
        profilePhoto.capture(){(image: UIImage?) -> Void in
            self.profileImage.image = image
        }
    }
    
// MARK: Add tags to textfields with consistencies that can be checked.
    func setTextFieldTags() {
        emailTextField.tag = 0
        postCodeTextField.tag = 1
    }
    
// MARK: Check if textfields are empy and have been filled in correctly.
    func addTextFieldTargets() {
        
        // Check if each textField is emty.
        firstNameTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        lastNameTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        dobTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        emailTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        addressLine1TextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        cityTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        postCodeTextField.addTarget(self, action: #selector(isEmptyField), for: .editingDidEnd)
        
        // Take profile photo if not running on a simulator.
        if Platform().isPhone() { firstNameTextField.addTarget(self, action: #selector(capturePhoto), for: .editingDidEnd) }
        
        // Check if email and post codes are correct.
        emailTextField.addTarget(self, action: #selector(checkField), for: .editingDidEnd)
        postCodeTextField.addTarget(self, action: #selector(checkField), for: .editingDidEnd)
    }
    
    
// MARK: If textFields arent empty show the Next button.
    func isEmptyField(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard
            
            let firstName = firstNameTextField.text, !firstName.isEmpty,
            let lastName = lastNameTextField.text, !lastName.isEmpty,
            let dob = dobTextField.text, !dob.isEmpty,
            let address = addressLine1TextField.text, !address.isEmpty,
            let city = cityTextField.text, !city.isEmpty,
            let postCode = postCodeTextField.text, !postCode.isEmpty,
            let email = emailTextField.text, !email.isEmpty
        
            else { return }
        
        showNextButton()
    }
    
// MARK: Check any fields if they contain a set format.
    func checkField(sender: UITextField) {
        
        var title:  String!
        
        // If textField is email then check it and present alertView if incorrect format entered.
        if sender.tag == 0 {
            
            if !checkTextField.email(sender: sender) {
                title = "Please enter valid Email Address"
                let alert = AlertHelper().warning(title: title, message: "", exit: false)
                self.present(alert, animated: true, completion: nil)
            }
        // If textField is post code then check it and present alertView if incorrect format entered.
        } else if sender.tag == 1 {
            
            if !checkTextField.postCode(sender: sender) {
                title = "Please enter valid Post Code"
                let alert = AlertHelper().warning(title: title, message: "", exit: false)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
//MARK: Show next button once all fields contain text.
    func showNextButton() {
        let button = NextButton()
        button.addTarget(self, action: #selector(nextButtonWasPressed), for: .touchUpInside)
        bottomView.addSubview(button)
    }
    
//MARK: Hides keyboard when tapping anywhere other than a textfield.
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
//MARK: Starts a custom activity indicator(NVActivityIndicatorView) then calls create account request.
    @IBAction func nextButtonWasPressed(sender: UIButton) {
        startAnimating(message: "Saving")
        createAccount()
    }
    
//MARK: Create params to send with api request to Stripe.
    func setParams() -> [String : Any] {
        
        // Seperate Date of birth into day month and year as Stripe requires this format.
        let dob = self.dobTextField.text!.components(separatedBy: "/")
        let params = [
            "first_name": firstNameTextField.text!.trim(),
            "last_name": lastNameTextField.text!.trim(),
            "line1": addressLine1TextField.text!.trim(),
            "city": cityTextField.text!.trim(),
            "postal_code": postCodeTextField.text!.trim(),
            "email": emailTextField.text!.trim(),
            "day": UInt(dob[0])! as UInt,
            "month": UInt(dob[1])! as UInt,
            "year": UInt(dob[2])! as UInt] as [String : Any]
        
        return params
    }
    
//MARK: Make request to Stripe to create a connect account.
    func createAccount() {
        
        request.post(params: self.setParams(), URLExtension: "account",
                         success: { response in
            
                            self.successfulRequest(response: response as AnyObject) },
                         
                         fail: { response in
                            
                            self.failedRequest(response: response as AnyObject)
        })
    }
    
//MARK: If api request is successful then save received account id, stop activity indicator and move onto next step in creating account.
    func successfulRequest(response: AnyObject) {
        self.stripeAccountID = response["id"] as! String
        createMainBillSplitter()
        self.stopAnimating()
        performSegue(withIdentifier: "segueToFinalRegistrationViewController", sender: self)
    }
    
//MARK: If api request fails, then create an alert view with reason why.
    func failedRequest(response: AnyObject) {
        self.stopAnimating()
        let alert = request.handleError(response["failed"] as! NSError)
        self.present(alert, animated: true, completion: nil)
    }
    
//MARK: Prepare dictionary of splitter values to be saved.
    func setmainBillSplitterValues() -> [String: Any] {
        
        let name = "\(firstNameTextField.text!) \(lastNameTextField.text!)"
        let email = emailTextField.text!
        let accountID = stripeAccountID

        var values = ["name": name,
                      "email": email,
                      "accountID": accountID,
                      "isMainBillSplitter": true,
                      "hasPaid": true] as [String : Any]
        if Platform().isPhone() { values["image"] = profileImage.image! }
        
        return values
    }

//MARK: If the api call is succesful then create and save the main bill splitter for the rest of the app.
    func createMainBillSplitter() {
        
        let context = UIApplication.shared.delegate as! AppDelegate
        
        CoreDataHelper().saveBillSplitter(context: context, values: self.setmainBillSplitterValues())
    }
}
