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

class InitialRegistrationViewController: UIViewController, UINavigationControllerDelegate,  UIImagePickerControllerDelegate, NVActivityIndicatorViewable {
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var quantity = CGFloat(200)
    var photoID = UIImage()
    var imagePicker: UIImagePickerController!
    var stripeAccountID = String()
    var fileID = String()
    var activityIndicator: NVActivityIndicatorView!
    var profileImage = UIImageView()
    
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
        
        lastNameTextField.text = "Stumfble"
        dobTextField.text = "20/02/1985"
        emailTextField.text = "ben@sdf.com"
        addressLine1TextField.text = "4 Chedworth House"
        cityTextField.text = "London"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InitialRegistrationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        addTextFieldTargets()
    }
    
    
    func addTextFieldTargets() {
        firstNameTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        if Platform.isPhone {
            firstNameTextField.addTarget(self, action: #selector(capturePhoto), for: .editingDidEnd)
        }
        lastNameTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        dobTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        addressLine1TextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        cityTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        postCodeTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
        postCodeTextField.addTarget(self, action: #selector(checkPostCodeField), for: .editingDidEnd)
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
            let email = emailTextField.text, !email.isEmpty

            else { return }
        
        createNextButton()
    }
    
    func checkEmailField(sender: UITextField) {
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)
        if emailTest.evaluate(with: sender.text) == false {
            let alert = UIAlertController(title: "Please Enter Valid Email Address", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            emailTextField.becomeFirstResponder()
        }
    }

    func checkPostCodeField(sender: UITextField) {
        let postCodeReg = "^([Gg][Ii][Rr] {0,}0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([AZa-z][0-9][A-Za-z])|([A-Za-‌​z][A-Ha-hJ-Yj-y]][0-9]?[A-Za-z])))) {0,}[0-9][A-Za-z]{2})$"

        let postCodeTest = NSPredicate(format: "SELF MATCHES %@", postCodeReg)
        if postCodeTest.evaluate(with: sender.text) == false {
            let alert = UIAlertController(title: "Please Enter Valid Post Code", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            postCodeTextField.becomeFirstResponder()
        }
    }
    
    func createNextButton() {
        let width = UIScreen.main.bounds.width
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        button.backgroundColor = UIColor(netHex: 0x000010)
        let title = NSAttributedString(string: "Next", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(nextButtonWasPressed), for: .touchUpInside)
        bottomView.addSubview(button)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func nextButtonWasPressed(sender: UIButton) {
        startAnimating(message: "Saving")
        createAccount()
    }
    
    func createAccount() {
        let manager = AFHTTPSessionManager()
        let dob = self.dobTextField.text!.components(separatedBy: "/")
        let URL = "https://splitterstripeservertest.herokuapp.com/account"
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
                
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(URL, parameters: params, progress: nil, success: {(_ task: URLSessionDataTask, _ responseObject: Any) -> Void in
            do {
                let response = try JSONSerialization.jsonObject(with: responseObject as! Data, options: .mutableContainers) as? [String: Any]
                self.stripeAccountID = response?["id"] as! String
                self.stopAnimating()
                self.goToFinalStage()
            } catch {
                print("Serialising new account json object went wrong.")
                self.stopAnimating()
            }
        }, failure: { (operation, error) -> Void in
            self.handleError(error as NSError)
            self.stopAnimating()
        })
    }
    
    func goToFinalStage() {
        createMainBillSplitter()
        performSegue(withIdentifier: "segueToFinalRegistrationViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToFinalRegistrationViewController" {
                
            let destinationVC = segue.destination as! FinalRegistrationViewController
            destinationVC.stripeAccountID = stripeAccountID
        }
    }
    
    func handleError(_ error: NSError) {
        let alert = UIAlertController(title: "Please Try Again", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        
        if Platform.isPhone {
            let imageData = UIImageJPEGRepresentation(profileImage.image!, 0.5)
            mainBillSplitter.setValue(imageData, forKey: "image")
        }

        mainBillSplitter.setValue(name.trim(), forKey: "name")
        mainBillSplitter.setValue(emailTextField.text?.trim(), forKey: "email")
        mainBillSplitter.setValue(stripeAccountID, forKey: "accountID")
        mainBillSplitter.setValue(true, forKey: "isMainBillSplitter")
        mainBillSplitter.setValue(true, forKey: "hasPaid")
        
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Platform.isPhone {
            session = AVCaptureSession()
            session!.sessionPreset = AVCaptureSessionPresetPhoto
            
            var frontCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            for device in availableCameraDevices as! [AVCaptureDevice] {
                if device.position == .front {
                    frontCamera = device
                }
            }
            
            var error: NSError?
            var input: AVCaptureDeviceInput!
            do {
                input = try AVCaptureDeviceInput(device: frontCamera)
            } catch let error1 as NSError {
                error = error1
                input = nil
                print(error!.localizedDescription)
            }
            
            if error == nil && session!.canAddInput(input) {
                session!.addInput(input)
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                
                if session!.canAddOutput(stillImageOutput) {
                    session!.addOutput(stillImageOutput)
                    session!.startRunning()
                }
            }
        }
    }

    
    func capturePhoto() {
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    self.profileImage.image = image
                }
            })
        }
    }
}
