//
//  DataManager.swift
//  ProDonor
//
//  Created by Vishnu on 02/09/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataManager {
    static let sharedInstance = DataManager()
    private init() {
        self.initializeMOCController()
    }
    
    //MARK: Properties
    private var rootManagedObjectContext: NSManagedObjectContext? // marked private
    
    func initializeMOCController() {
        if self.rootManagedObjectContext == nil {
            self.rootManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        }
    }
    
    
    func storeDatabase(data: [NSObject : AnyObject],isAccepted : Bool, havingCallback callback: (Bool) -> Void) {
        self.rootManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("Requester",inManagedObjectContext: self.rootManagedObjectContext!)
        let database = NSManagedObject(entity: entityDescription!,insertIntoManagedObjectContext: self.rootManagedObjectContext!) as! Requester
        database.donorId = Int(data["gcm.notification.request_id"] as! String)!
        database.username = data["gcm.notification.name"] as? String
        database.comment = data["gcm.notification.comment"] as? String
        database.timeStamp = NSDate()
        database.isAccepted = isAccepted
        do {
            try self.rootManagedObjectContext!.save()
            callback(true)
        } catch {
            print("Error in storing database \(error)")
            callback(false)
        }
    }
    
    func donorDatabase(data: [NSObject : AnyObject], havingCallback callback: (Bool) -> Void){
        let entityDescription = NSEntityDescription.entityForName("DonorDetail",inManagedObjectContext: self.rootManagedObjectContext!)
        let database = NSManagedObject(entity: entityDescription!,insertIntoManagedObjectContext: self.rootManagedObjectContext!) as! DonorDetail
        database.id = Int(data["gcm.notification.request_id"] as! String)!
        database.username = data["gcm.notification.name"] as? String
        database.mobilenumber = data["gcm.notification.mobile_number"] as? String
        database.timeStamp = NSDate()
        do {
            try self.rootManagedObjectContext!.save()
            callback(true)
        } catch {
            print("Error in storing database \(error)")
            callback(false)
        }
    }

    
    func fetchFromDatabase(entityName:String,havingCallback callback: (Bool,NSArray?) -> Void){
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext)
        let sortDiscriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDiscriptor]
        fetchRequest.entity = entityDescription
        do {
            let result = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext.executeFetchRequest(fetchRequest)
            callback(true,result)
            print(result as NSArray)
        } catch {
            let fetchError = error as NSError
            callback(false,nil)
            print(fetchError)
        }
    }


}