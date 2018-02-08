//
//  AlertController.swift
//  ProDonor
//
//  Created by Varun on 02/09/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class AlertController: NSObject {
    //MARK: Methods
    
    class func showAlertControllerHaving(title title: String?, andMessage message: String?) {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let rootViewController = appDelegate?.window?.rootViewController as! UINavigationController
        var topViewController = rootViewController.viewControllers.last
        while ((topViewController?.presentedViewController) != nil) {
            topViewController = topViewController?.presentedViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.Default) { (action) -> Void in
            // do nothing
            topViewController?.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(alertAction)
        
        topViewController?.presentViewController(alertController, animated: true, completion: { () -> Void in
            // do nothing
        })
    }
    
    class func showAlertControllerWithOptions(title title: String?, andMessage message: String?,andData userInfo: [NSObject : AnyObject]) {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let rootViewController = appDelegate?.window?.rootViewController as! UINavigationController
        var topViewController = rootViewController.viewControllers.last
        while ((topViewController?.presentedViewController) != nil) {
            topViewController = topViewController?.presentedViewController
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertCancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            DataManager.sharedInstance.storeDatabase (userInfo,isAccepted: false, havingCallback: { (status) -> Void in
                if status{
                    print("storedsucessfully")
                }
            })
        })
        alertController.addAction(alertCancelAction)
        
        let alertAcceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            appDelegate!.updateRequest(userInfo["gcm.notification.request_id"] as! String)
            DataManager.sharedInstance.storeDatabase (userInfo,isAccepted: true, havingCallback: { (status) -> Void in
                if status{
                    print("storedsucessfully")
                }
            })
        })
        alertController.addAction(alertAcceptAction)
        topViewController?.presentViewController(alertController, animated: true, completion: { () -> Void in
            // do nothing
        })
    }
    
    
    class func showLocationSettingsAlert(havingTitle title: String, andMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let settingsAction = UIAlertAction(title: NSLocalizedString("SettingsTitle", comment: ""), style: UIAlertActionStyle.Default) { (action) -> Void in
            // open settings tab
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: UIApplicationOpenSettingsURLString)!) {
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CancelTitle", comment: ""), style: UIAlertActionStyle.Cancel) { (action) -> Void in
            // repeat
            LocationManager.sharedInstance.checkValidityOfAuthorizationStatus(CLLocationManager.authorizationStatus())
        }
        alertController.addAction(cancelAction)
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let rootViewController = appDelegate?.window?.rootViewController as! UINavigationController
        var topViewController = rootViewController.viewControllers.last
        while ((topViewController?.presentedViewController) != nil) {
            topViewController = topViewController?.presentedViewController
        }
        topViewController?.presentViewController(alertController, animated: true, completion: { () -> Void in
            // do nothing
        })
    }
}
