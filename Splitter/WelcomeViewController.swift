//
//  WelcomeViewController.swift
//  Splitter
//
//  Created by Wayne Rumble on 16/01/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Photos

class WelcomeViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCameraUsePermission()
    }
    
//Get permission to use camera
    func getCameraUsePermission() {
        
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(_ granted: Bool) -> Void in
            // if permission isnt received present alerview then quit app, otherwise request location permission.
            if !granted {
                
                self.presentSplitterClosingAlert()
            } else {
                
                self.getPhotoLibraryUsePermission()
            }
        })
    }
    
//Get permission to use photo library
    func getPhotoLibraryUsePermission() {
        
        PHPhotoLibrary.requestAuthorization() { (status) -> Void in
            
            switch status {
                
            case .authorized:
                
                self.getLocationAccessPermition()
                
            case .denied, .restricted:
                
                self.presentSplitterClosingAlert()
                
            case .notDetermined: break
                // won't happen but has to be here
            }
        }
    }
    
//Get permission to use location
    func getLocationAccessPermition() {
        // Request user location permission, accepting will allow nearest location suggestions, if no then the user can enter their location themselves.
        self.locationManager.requestWhenInUseAuthorization()
        
        
    }
    
//Display alert if camera or photo library access refused
    func presentSplitterClosingAlert() {
        
        // AlertView if user doesnt allow use of their camera, this is essential to the app so will quit when they press ok. Currently user will have to delete and download app again as i havent looked into how to ask for permission again.
        let title = "Woops!"
        let message = "The camera and photo library are essential for Splitter to run, so it will now close. To use Splitter please re install the app and accept use of camera and photo library next time."
        let alert = AlertHelper().warning(title: title, message: message, exit: true)

        self.present(alert, animated: true, completion: nil)
    }
}
