//
//  NetworkAccess.swift
//  ProDonor
//
//  Created by Naveen on 31/08/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
import Alamofire
class NetworkAccess {
    class func processRequestDictionary(parameters:[String:AnyObject], URL:String, completion:([String:AnyObject])->()) {
        Alamofire.request(.POST, URL, parameters: parameters, encoding: .URL).responseJSON { response in
            if let json = response.result.value as? [String:AnyObject] {
                print("json dict is \(json)")
                if let data = json["data"] as? [String:AnyObject] {
                    completion(data)
                }
            }
            else {
                print("json parsing error")
            }
        }
    }
    
    class func makeConnectionAtURL(URL url:String, withParameter parameters: [String:AnyObject], onCompletion callback:(AnyObject?, NSError?)->Void) {
        Alamofire.request(.POST, url, parameters: parameters, encoding: .URL).validate().responseJSON { (response) -> Void in
            if response.result.isSuccess {
                let data = response.result.value as! NSDictionary
                if (data.objectForKey("error") as! Int) == 0 {
                    let object = data.objectForKey("data")
                    callback(object, nil)
                } else {
                    callback(nil, NSError(domain: "ProDonor:NetworkAccess:makeConnection", code: 1010, userInfo: ["developerInfo":"The response was not in the appropriate format"]))
                }
            } else {
                callback(nil, response.result.error)
            }
        }
    }
}