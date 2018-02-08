//
//  RegistrationService.swift
//  ProDonor
//
//  Created by Naveen on 31/08/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
import KeychainSwift
class RegistrationService {
    let keychain = KeychainSwift()
    func registerUserWithDeviceToken(deviceToken:String, gcmToken:String, completion:()->()) {
        let parameters = ["devicetoken":deviceToken,"gcmtoken":gcmToken]
        NetworkAccess.processRequestDictionary(parameters, URL: Constants.URL.Registration) { (response) -> () in
            dispatch_async(dispatch_get_main_queue()) {
                print("complete \(response)")
                let userid = response["user_id"] as! Int
                let verified = response["isverified"] as? Int
                self.saveUserId(userid)
                self.saveDeviceToken(deviceToken)
                if verified != nil {
                    self.setVerified(verified!)
                }
                print("user value is \(self.getUserID()) device token is \(self.getDeviceToken())")
                completion()
            }
        }
    }
    
    func updateUser(parameters:[String:AnyObject], completion:([String:AnyObject])->()) {
        NetworkAccess.processRequestDictionary(parameters, URL: Constants.URL.Registration) { (response) -> () in
            dispatch_async(dispatch_get_main_queue()) {
                print("complete \(response)")
                completion(response)
            }
        }
    }
    func updateRequest(parameters:[String:AnyObject], completion:([String:AnyObject])->()) {
        NetworkAccess.processRequestDictionary(parameters, URL: Constants.URL.updateRequest) { (response) -> () in
            dispatch_async(dispatch_get_main_queue()) {
                print("complete \(response)")
                completion(response)
            }
        }
    }
    
    func saveRegistration() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "registered")
        //keychain.set(true, forKey: "registered")
    }
    
    func isRegistered() -> Bool? {
        return NSUserDefaults.standardUserDefaults().boolForKey("registered")
        //return keychain.getBool("registered")
    }
    
    func clearKeychain() {
        /*keychain.delete("user_id")
        keychain.delete("devicetoken")
        keychain.delete("verified")*/
        keychain.clear()
    }
    func updateUserVerified() {
        let parameters:[String:AnyObject] = ["userid":getUserID()!,"verifystatus":"true"]
        NetworkAccess.processRequestDictionary(parameters, URL: Constants.URL.Verify) { (response) -> () in
            print("verification complete")
        }
    }
    func saveUserId(userid:Int) {
        keychain.set(String(userid), forKey: "user_id")

    }
    
    func saveGCMToken(gcmToken:String) {
        keychain.set(gcmToken, forKey: "gcmtoken")
    }
    
    func getGCMToken() -> String? {
        return keychain.get("gcmtoken")
    }
    
    func saveDeviceToken(deviceToken:String) {
        keychain.set(deviceToken, forKey: "devicetoken")
        
    }
    
    func getDeviceToken() -> String? {
        if let deviceToken = keychain.get("devicetoken") {
            return deviceToken
        }
        return nil
    }
    
    func getUserID() -> Int? {
        if let userid = keychain.get("user_id") {
            return Int(userid)
        }
        return nil
    }
    
    func setVerified(verified:Int) {
        let isVerified = (verified != 0 ? "1" : "0")
        let keychain = KeychainSwift()
        keychain.set(String(isVerified), forKey: "verified")
    }
    
    func getVerified() -> Int? {
        let keychain = KeychainSwift()
        if let verified = keychain.get("verified") {
            return Int(verified)
        }
        return nil
    }
}