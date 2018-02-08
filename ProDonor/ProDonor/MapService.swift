//
//  MapService.swift
//  ProDonor
//
//  Created by Varun on 02/09/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
import CoreLocation


class MapService: NSObject {
    class func searchDonorsForLocation(location: CLLocation, havingCallback callback:(NSArray?) -> Void) {
        let bodyParameters: [String: AnyObject] = ["pinlat":location.coordinate.latitude, "pinlong":location.coordinate.longitude]
        NetworkAccess.makeConnectionAtURL(URL: Constants.URL.search, withParameter: bodyParameters) { (object, error) -> Void in
            //something
            if error == nil {
                if let donors = object as? NSArray {
                    for donor in donors {
                        print("CALLBACK: \(donor["id"]) \(donor as! NSDictionary)")
                    }
                    callback(donors)
                }
            } else {
                callback(nil)
            }
        }
    }
    
    class func sendRequestToDonorHavingID(donorId id: String, withComment comment: String, fromRequesteeID requesteeID: Int, havingCallBack callback: (NSError?)-> Void) {
        let bodyParameters: [String: AnyObject] = ["donorid":id,"comment":comment,"requesterid":requesteeID]
        NetworkAccess.makeConnectionAtURL(URL: Constants.URL.newRequest, withParameter: bodyParameters) { (object, error) -> Void in
            if error == nil {
                callback(nil)
            } else {
                callback(error)
            }
        }
    }
    
    class func updateDonorLocation(location: CLLocation, havingID id: Int, withCallback callback: (NSError?) -> Void) {
        let bodyParameters: [String: AnyObject] = ["userid":id, "latitude":location.coordinate.latitude, "longitude":location.coordinate.longitude]
        NetworkAccess.makeConnectionAtURL(URL: Constants.URL.update, withParameter: bodyParameters) { (object, error) -> Void in
            if error == nil {
                callback(nil)
            } else {
                callback(error)
            }
        }
    }
}