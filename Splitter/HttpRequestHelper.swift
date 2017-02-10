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
    
    func post(params: [String: Any], URLExtension: String, success:@escaping (([String: Any]) -> Void), fail:@escaping (([String: Any]) -> Void)) {
        
        let URL = baseURL + URLExtension
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(URL, parameters: params, progress: nil, success: {(_ task: URLSessionDataTask, _ responseObject: Any) -> Void in
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
    
    func handleError(_ error: NSError) -> UIAlertController {
        let alert = UIAlertController(title: "Please Try Again", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
}
