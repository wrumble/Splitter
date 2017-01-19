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

class InitialRegistrationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NVActivityIndicatorViewable {
    
    let device = Device()
    
    var quantity = CGFloat(200)
    var photoID = UIImage()
    var imagePicker: UIImagePickerController!
    var stripeAccountID = String()
    var fileID = String()
    var activityIndicator: NVActivityIndicatorView!
    
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
        
        firstNameTextField.text = "Scodftt"
        lastNameTextField.text = "Stumfble"
        dobTextField.text = "20/02/1985"
        emailTextField.text = "ben@sdf.com"
        addressLine1TextField.text = "4 Chedworth House"
        cityTextField.text = "London"
        
        if device == .iPhone4 || device == .iPhone4s { quantity = 100 }
        
        if device == .iPhone4 || device == .iPhone4s || device == .iPhone5 || device == .iPhone5c || device == .iPhone5s {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }

        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InitialRegistrationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        addTextFieldTargets()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - quantity
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height - quantity
            }
        }
    }
    
    func addTextFieldTargets() {
        firstNameTextField.addTarget(self, action: #selector(checkFields), for: .editingDidEnd)
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
            
        }
    }

    func checkPostCodeField(sender: UITextField) {
        let postCodeReg = "^([Gg][Ii][Rr] {0,}0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([AZa-z][0-9][A-Za-z])|([A-Za-‌​z][A-Ha-hJ-Yj-y]][0-9]?[A-Za-z])))) {0,}[0-9][A-Za-z]{2})$"

        let postCodeTest = NSPredicate(format: "SELF MATCHES %@", postCodeReg)
        if postCodeTest.evaluate(with: sender.text) == false {
            let alert = UIAlertController(title: "Please Enter Valid Post Code", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
        startAnimating(message: "Saving")
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
    
//    func secretPhotoCapture() {
//    
//        var session = AVCaptureSession()
//        var frontalCamera: AVCaptureDevice?
//        var allCameras: [AVCaptureDevice] = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
//        // Find the frontal camera.
//        for i in 0..<allCameras.count {
//            
//            var camera: AVCaptureDevice? = allCameras[i]
//            if camera?.position == .front {
//                frontalCamera = camera
//            }
//        }
//        // If we did not find the camera then do not take picture.
//        if frontalCamera != nil {
//            // Start the process of getting a picture.
//            session = AVCaptureSession()
//            // Setup instance of input with frontal camera and add to session.
//            var error: Error?
//            var input = try! AVCaptureDeviceInput(device: frontalCamera)
//            if !(error != nil) && session.canAddInput(input) {
//                // Add frontal camera to this session.
//                session.addInput(input)
//                // We need to capture still image.
//                var output = AVCaptureStillImageOutput()
//                // Captured image. settings.
//                output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
//            
//            
//                if session.canAddOutput(output) {
//                    session.addOutput(output)
//                    var videoConnection: AVCaptureConnection? = nil
//                    for connection: AVCaptureConnection in output.connections {
//                        for port: AVCaptureInputPort in connection.inputPorts() {
//                            if port.mediaType.isEqual(AVMediaTypeVideo) {
//                                videoConnection = connection
//                                break
//                            }
//                        }
//                    
//                        if videoConnection { break }
//                    }
//                    if (videoConnection != nil) {
//                        session.startRunning()
//                        output.captureStillImageAsynchronously(from: (connection: videoConnection), completionHandler: {(_ imageDataSampleBuffer: CMSampleBuffer?, _ error: Error) -> Void in
//                            if imageDataSampleBuffer != nil {
//                                var imageData: Data? = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
//                                var photo = UIImage(data: imageData)
//                            }
//                        })
//                    }
//                }
//            }
//        }
//    }
    
}
