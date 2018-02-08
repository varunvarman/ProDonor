//
//  Constants.swift
//  ProDonor
//
//  Created by Varun on 30/08/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
class Constants: NSObject {
    struct APIKEYS {
        static let googleMapsAPIKey = "AIzaSyBP8HeGd1NFlzy6HDrg_GlT1pW42b8_0zA"
    }
    
    struct ImageName {
        static let bloodDrop = "blooddrop"
        static let bloodDonor = "blooddonor"
        static let userLocation = "userlocation"
        static let filter = "filtericon"
        static let refreshIcon = "refreshicon"
        static let requesterIcon = "requestericon"
        static let donorIcon = "donoricon"
        static let phone = "phone"
        static let titleIcon = "icontitle"
    }
    
    struct DataConstants {
        static let BloodGroups = ["O +", "A +", "B +", "AB +", "O -", "A -", "AB -", "B -"]
    }
    
    struct URL {
        static let Registration = "http://divyanshunegi.com/prodonor/register"
        static let Verify = "http://divyanshunegi.com/prodonor/verify"
        static let search = "http://www.divyanshunegi.com/prodonor/search"
        static let newRequest = "http://www.divyanshunegi.com/prodonor/newrequest"
        static let update = "http://www.divyanshunegi.com/prodonor/update"
        static let updateRequest = "http://www.divyanshunegi.com/prodonor/updaterequest"
    }
    
    struct Notifications {
        static let LoadingComplete = "loadingcomplete"
        static let registrationComplete = "registrationComplete"
    }
}
