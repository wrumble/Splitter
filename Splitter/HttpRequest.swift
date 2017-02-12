//
//  HttpRequestHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 09/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import AFNetworking

class HttpRequest {
    
    let manager = AFHTTPSessionManager()
    let baseURL = "https://splitterstripeservertest.herokuapp.com/"
    
    init() {
        setSerializers()
    }
    
//Set Session managers serializers.
    func setSerializers() {
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
    }
    
//Add extension to baseURL
    func setURL(URLExtension: String) -> String {
        return baseURL + URLExtension
    }
    
    
//Make standard api request with params.
    func post(params: [String: Any], URLExtension: String, success:@escaping (([String: Any]) -> Void), fail:@escaping (([String: Any]) -> Void)) {
                
        manager.post(self.setURL(URLExtension: URLExtension), parameters: params, progress: nil,
                success: {(_ task: URLSessionDataTask, _ responseObject: Any) -> Void in
                            do {
                                let response = try JSONSerialization.jsonObject(with: responseObject as! Data, options: .mutableContainers) as! [String: Any]
                                success(response)
                                
                            } catch {
                                print("Serialising new account json object went wrong.")
                            }
                    
                }, failure: { (operation, error) -> Void in
                            let response = ["failed": error]
                            fail(response)
        })
    }
    
//Make api request and pass imageData with it as well as params.
    func postWithImageData(params: [String: Any], URLExtension: String, imageData: Data, success:@escaping (([String: Any]) -> Void), fail:@escaping (([String: Any]) -> Void)) {
        
        manager.post(self.setURL(URLExtension: URLExtension), parameters: params, constructingBodyWith: { (formData: AFMultipartFormData!) -> Void in
            formData.appendPart(withFileData: imageData, name: "file", fileName: "photoID.jpg", mimeType: "image/jpeg")},
                     success: {(_ task: URLSessionDataTask, _ responseObject: Any) -> Void in
                        
                                do {
                                    
                                    let response = try JSONSerialization.jsonObject(with: responseObject as! Data, options: .mutableContainers) as? [String: Any]
                                    success(response!)
                                } catch {
                                    print("Serialising account id json object went wrong.")
                                }
                        
                    }, failure: { (operation, error) -> Void in
                        
                                let response = ["failed": error]
                                fail(response)
        })
        
    }
    
//Create alertView if api rquest fails for whatever reason.
    func handleError(_ error: NSError) -> UIAlertController {
        let alert = UIAlertController(title: "Please Try Again", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
}
