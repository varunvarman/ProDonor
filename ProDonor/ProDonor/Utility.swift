//
//  Utility.swift
//  ProDonor
//
//  Created by Naveen on 31/08/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
class Utility {
    class func stringForDeviceToken(deviceToken: NSData) -> String {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        print("tokenString: \(tokenString)")
        return tokenString
    }
    
    class func convertBloodGroupForJson(group:String) -> String{
        var bgroup = group.stringByReplacingOccurrencesOfString(" +", withString: "P")
        bgroup = bgroup.stringByReplacingOccurrencesOfString(" -", withString: "N")
        return bgroup
    }
    
    class func convertJsonToBloodGroup(group: String) -> String {
        var bgroup = group.stringByReplacingOccurrencesOfString("P", withString: " +")
        bgroup = bgroup.stringByReplacingOccurrencesOfString("N", withString: " -")
        bgroup = bgroup.stringByReplacingOccurrencesOfString("M", withString: " -")
        return bgroup
    }
}