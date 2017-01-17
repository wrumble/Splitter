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

class InitialRegistrationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var photoID = UIImage()
    var imagePicker: UIImagePickerController!
    var stripeAccountID = String()
    var fileID = String()
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var addressLine1TextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postCodeTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.text = "Scodftt"
        lastNameTextField.text = "Stumfble"
        dobTextField.text = "20/02/1985"
        addressLine1TextField.text = "4 Chedworth House"
        cityTextField.text = "London"
        postCodeTextField.text = "sw65al"
        countryTextField.text = "GB"
        emailTextField.text = "ben@sdf.com"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InitialRegistrationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        addTextFieldTargets()
    }
    
    func addTextFieldTargets() {
        firstNameTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        lastNameTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        dobTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        addressLine1TextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        cityTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        postCodeTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        countryTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        emailTextField.addTarget(self, action: #selector(checkEmailField), for: .editingDidEnd)
        emailTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
    }
    
    
    func checkFields(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard
            let firstName = firstNameTextField.text, !firstName.isEmpty,
            let lastName = lastNameTextField.text, !lastName.isEmpty,
            let dob = dobTextField.text, !dob.isEmpty,
            let address = addressLine1TextField.text, !address.isEmpty,
            let city = cityTextField.text, !city.isEmpty,
            let postCode = postCodeTextField.text, !postCode.isEmpty,
            let country = countryTextField.text, !country.isEmpty,
            let email = emailTextField.text, !email.isEmpty

            else { return }
        
        createNextButton()
    }
    
    func checkEmailField(sender: UITextField) {
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)
        if emailTest.evaluate(with: sender.text) == false {
            UIAlertView(title: "", message: "Please Enter Valid Email Address.", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    func createNextButton() {
        let width = UIScreen.main.bounds.width
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        button.backgroundColor = UIColor.black
        let title = NSAttributedString(string: "Next", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(nextButtonWasPressed), for: .touchUpInside)
        bottomView.addSubview(button)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func nextButtonWasPressed(sender: UIButton) {
        createAccount()
    }
    
    func createAccount() {
        let manager = AFHTTPSessionManager()
        let dob = self.dobTextField.text!.components(separatedBy: "/")
        let URL = "https://splitterstripeservertest.herokuapp.com/account"
        let params = [
                    "first_name": firstNameTextField.text!,
                    "last_name": lastNameTextField.text!,
                    "line1": addressLine1TextField.text!,
                    "city": cityTextField.text!,
                    "postal_code": postCodeTextField.text!,
                    "country": countryTextField.text!,
                    "email": emailTextField.text!,
                    "day": UInt(dob[0])! as UInt,
                    "month": UInt(dob[1])! as UInt,
                    "year": UInt(dob[2])! as UInt] as [String : Any]
                
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(URL, parameters: params, progress: nil, success: {(_ task: URLSessionDataTask, _ responseObject: Any) -> Void in
            do {
                let response = try JSONSerialization.jsonObject(with: responseObject as! Data, options: .mutableContainers) as? [String: Any]
                self.stripeAccountID = response?["id"] as! String
                self.goToFinalStage()
            } catch {
                print("Serialising new account json object went wrong.")
            }
        }, failure: { (operation, error) -> Void in
            self.handleError(error as NSError)
        })
    }
    
    func goToFinalStage() {
        performSegue(withIdentifier: "segueToFinalRegistrationViewController", sender: self)
        createMainBillSplitter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToFinalRegistrationViewController" {
                
            let destinationVC = segue.destination as! FinalRegistrationViewController
            
            destinationVC.stripeAccountID = stripeAccountID
            
        }
    }
    
    func handleError(_ error: NSError) {
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
    }

    @IBAction func datePicker(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
    }

    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dobTextField.text = dateFormatter.string(from: sender.date)
    }
    
    func createMainBillSplitter() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "BillSplitter", in: managedContext)
        let mainBillSplitter = NSManagedObject(entity: entity!, insertInto: managedContext)
        let name = "\(firstNameTextField.text!) \(lastNameTextField.text!)"

        mainBillSplitter.setValue(name, forKey: "name")
        mainBillSplitter.setValue(emailTextField.text, forKey: "email")
        mainBillSplitter.setValue(stripeAccountID, forKey: "accountID")
        mainBillSplitter.setValue(true, forKey: "isMainBillSplitter")
        mainBillSplitter.setValue(true, forKey: "hasPaid")
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        

    }
    
}
