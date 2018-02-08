//
//  AppDelegate.swift
//  ProDonor
//
//  Created by Varun on 30/08/16.
//  Copyright © 2016 DC. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import Fabric
import DigitsKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCMReceiverDelegate {
    var connectedToGCM = false
    var window: UIWindow?
    var registrationOptions = [String: AnyObject]()
     var gcmSenderID: String?
    var registrationToken: String?
    var deviceToken:NSData?
    let registrationService = RegistrationService()
    let subscriptionTopic = "/topics/global"
    var subscribedToTopic = false
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    var loadingComplete = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Digits.self])
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(Constants.APIKEYS.googleMapsAPIKey)
        Digits.sharedInstance().logOut() 
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotificationTypes(types)
        }

        
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        if let notificationPackage = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] {
            processNotificationWithUserInfo(notificationPackage as! [NSObject : AnyObject])
        }
        return true
    }
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
                options: nil, handler: {(error:NSError?) -> Void in
                    if let error = error {
                        // Treat the "already subscribed" error more gently
                        if error.code == 3001 {
                            print("Already subscribed to \(self.subscriptionTopic)")
                        } else {
                            print("Subscription failed: \(error.localizedDescription)");
                        }
                    } else {
                        self.subscribedToTopic = true;
                        NSLog("Subscribed to \(self.subscriptionTopic)");
                    }
            })
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        GCMService.sharedInstance().disconnect()
        // [START_EXCLUDE]
        self.connectedToGCM = false
        // [END_EXCLUDE]

    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Connect to the GCM server to receive non-APNS notifications
        GCMService.sharedInstance().connectWithHandler({(error:NSError?) -> Void in
            if let error = error {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print("Connected to GCM")
                // [START_EXCLUDE]
                self.subscribeToTopic()
                // [END_EXCLUDE]
            }
        })
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.deviceToken = deviceToken
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
            kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
            print("Registration for remote notification failed with error: \(error.localizedDescription)")
            // [END receive_apns_token_error]
    }
    
    func processNotificationWithUserInfo(userInfo: [NSObject : AnyObject]) {
        print("Notification received", userInfo)
        
        // requester
        if (userInfo["gcm.notification.type"] as! String == "request"){
            if (UIApplication.sharedApplication().applicationState == UIApplicationState.Inactive){
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    AlertController.showAlertControllerWithOptions(title: userInfo["gcm.notification.name"] as? String, andMessage: userInfo["gcm.notification.comment"] as? String,andData: userInfo )
                }
            }else{
                AlertController.showAlertControllerWithOptions(title: userInfo["gcm.notification.name"] as? String, andMessage: userInfo["gcm.notification.comment"] as? String,andData: userInfo )
            }
        }
        // accepted from donor
        if (userInfo["gcm.notification.type"] as! String == "accepted"){
            DataManager.sharedInstance.donorDatabase (userInfo, havingCallback: { (status) -> Void in
                if status{
                    print("storedsucessfully")
                }
            })
            if (UIApplication.sharedApplication().applicationState == UIApplicationState.Inactive){
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    AlertController.showAlertControllerHaving(title:userInfo["gcm.notification.name"] as? String, andMessage: userInfo["gcm.notification.mobile_number"] as? String)
                }
            }else{
                AlertController.showAlertControllerHaving(title:userInfo["gcm.notification.name"] as? String, andMessage: userInfo["gcm.notification.mobile_number"] as? String)
            }
        }
        
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        processNotificationWithUserInfo(userInfo)
    }
    
    func updateRequest(requestId: String){
        let parameters:[String:AnyObject] = ["requestid":requestId, "accepted":"true"]
        registrationService.updateRequest(parameters) {_ in 
            
        }
        
    }
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            if let isRegistered = registrationService.isRegistered() {
                if (isRegistered == false) {
                    registrationService.registerUserWithDeviceToken(Utility.stringForDeviceToken(self.deviceToken!),gcmToken:self.registrationToken!) {
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.LoadingComplete, object: self)
                        self.loadingComplete = true
                    }
                }
                else {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.registrationComplete, object: self)
                    self.loadingComplete = true
                }
            }
            else {
                registrationService.registerUserWithDeviceToken(Utility.stringForDeviceToken(self.deviceToken!),gcmToken:self.registrationToken!) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.LoadingComplete, object: self)
                    self.loadingComplete = true
                }
            }
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dietcode.ProDonor" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ProDonor", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

extension AppDelegate: GGLInstanceIDDelegate {
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
        
    }
    
    
}




