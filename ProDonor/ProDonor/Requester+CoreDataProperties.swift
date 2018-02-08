//
//  Requester+CoreDataProperties.swift
//  ProDonor
//
//  Created by Varun on 05/09/16.
//  Copyright © 2016 DC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Requester {

    @NSManaged var comment: String?
    @NSManaged var donorId: NSNumber?
    @NSManaged var isAccepted: NSNumber?
    @NSManaged var username: String?
    @NSManaged var timeStamp: NSDate?

}
