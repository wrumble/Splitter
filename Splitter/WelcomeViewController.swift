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

class WelcomeViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getImageCapturePermission()
    }
    
// MARK: Photo Permission
    
    func getImageCapturePermission() {
        
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(_ granted: Bool) -> Void in
            // if permission isnt received present alerview then quit app, otherwise request location permission.
            if !granted {
                self.presentSplitterClosingAlert()
            } else {
                self.getLocationAccessPermition()
            }
        })
    }
    
// MARK: Location Permission
    
    func getLocationAccessPermition() {
        // Request user location permission, accepting will allow nearest location suggestions, if no then the user can enter their location themselves.
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func presentSplitterClosingAlert() {
        
        // AlertView if user doesnt allow use of their camera, this is essential to the app so will quit when they press ok. Currently user will have to delete and download app again as i havent looked into how to ask for permission again.
        let title = "Woops!"
        let message = "Camera is essential for Splitter to run and will now close. To use Splitter please accept use of the camera next time, after reloading app."
        let alert = AlertHelper().warning(title: title, message: message, exit: true)

        self.present(alert, animated: true, completion: nil)
    }
}
