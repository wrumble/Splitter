//
//  ProfilePhotoHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 09/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import AVFoundation

//MARK: This takes a sneaky/unflattering profile photo just after you enter your name.
class ProfilePhoto {
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var error: NSError?
    var input: AVCaptureDeviceInput!
    var frontCamera: AVCaptureDevice!
    
//MARK: Begin the image capturing session
    func startSession() {
        
        if Platform().isPhone() {
            session = AVCaptureSession()
            session!.sessionPreset = AVCaptureSessionPresetPhoto
            
            self.findFrontCamera()
            self.setErrorAndInput()
            self.beginSession()
        }
    }
    
//Assigns the front camera of the device as the AVCapture device.
    func findFrontCamera() {
        frontCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .front {
                frontCamera = device
            }
        }
    }
    
//Assign errors and input devices.
    func setErrorAndInput() {
        do {
            input = try AVCaptureDeviceInput(device: frontCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
    }
    
//Begin the AVCapture session.
    func beginSession() {
        if session!.canAddInput(input) {
            session!.addInput(input)
            self.setStillImageOutput()
            
            if session!.canAddOutput(stillImageOutput) {
                session!.addOutput(stillImageOutput)
                session!.startRunning()
            }
        }
    }
    
    func setStillImageOutput() {
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
    }
    
//MARK: This captures the profile photo and returns it on completion.
    func capture(completion: @escaping (UIImage?) -> Void) {
        
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                if sampleBuffer != nil {
                    let cgImageRef = self.setBufferData(sampleBuffer: sampleBuffer!)
                    let image: UIImage! = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
                    completion(image)
                } else {
                    completion(nil)
                }
            })
        } else {
            completion(nil)
        }
    }
    
    
    func setBufferData(sampleBuffer: CMSampleBuffer ) -> CGImage {
        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
        let dataProvider = CGDataProvider(data: imageData as! CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        return cgImageRef!
    }
}
