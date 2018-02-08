//
//  MapViewController.swift
//  ProDonor
//
//  Created by Varun on 01/09/16.
//  Copyright © 2016 DC. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class MapViewController: UIViewController, LocationManagerDelegate, GMSMapViewDelegate, FilterViewControllerDelegate {
    
    //MARK: Properties
    var location: CLLocation?
    var mapView: GMSMapView?
    var userMarker: GMSMarker?
    var pointerPin: UIImageView?
    var previousIdleLocation: CLLocation?
    var donors: [Donor] = []
    var donorsToDispaly: [Donor] = []
    var filterArray: [String] = []
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    let lastUserLocationKey = "lastSavedUserLocation"
    var isFirstLoad: Bool = true
    let requestSegueIdentifier = "makeRequest"
    let filterSegueIdentifier = "filter"
    let hundredKilometers:Double = 100000
    var donorMarkerMapping:[GMSMarker:Donor] = [GMSMarker:Donor]()
    var refreshBarButton: UIBarButtonItem!
    var defaultLocation: CLLocation {
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let coordinates: [String:Double] = ["lat":newValue.coordinate.latitude, "long":newValue.coordinate.longitude]
            userDefaults.setObject(coordinates, forKey: lastUserLocationKey)
            userDefaults.synchronize()
        }
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            guard let coordinates = userDefaults.objectForKey(lastUserLocationKey) else {
                return CLLocation(latitude: Double(15.498612), longitude: Double(73.829134))
            }
            return CLLocation(latitude: coordinates.objectForKey("lat") as! Double, longitude: coordinates.objectForKey("long") as! Double)
        }
    }
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("ProDonor: Creation of dev branch.")
        let filterButton = UIBarButtonItem(image: UIImage(named: Constants.ImageName.filter), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("showFilterViewController"))
        let refreshButton = UIBarButtonItem(image: UIImage(named: Constants.ImageName.refreshIcon)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("refreshMapViewWithDonors"))
        self.refreshBarButton = refreshButton
        let requesterButton = UIBarButtonItem(image: UIImage(named: Constants.ImageName.requesterIcon)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("requesterTableButtonAction"))
        let donorButton = UIBarButtonItem(image: UIImage(named: Constants.ImageName.donorIcon)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("donorTableButtonAction"))
//        self.navigationItem.rightBarButtonItems = [filterButton,donorButton]
//        self.navigationItem.leftBarButtonItems = [refreshButton,requesterButton]
        self.navigationController?.navigationBar.tintColor = UIColor(red: 215.0/255.0, green: 45.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        self.activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: UIScreen.mainScreen().bounds.height/2)
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        self.initializeMapView()
        self.initializePointerForMap()
        toolbarItems = [refreshButton,UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil),requesterButton,UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil),donorButton,UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil),filterButton]
        self.navigationController!.setToolbarHidden(false, animated: false)
        self.navigationController?.toolbar.tintColor = UIColor(red: 215.0/255.0, green: 45.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        self.navigationController?.toolbar.barTintColor = UIColor(red: 229.0/255.0, green: 227.0/255.0, blue: 236.0/255.0, alpha: 1.0)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.sharedInstance.delegate = self
        LocationManager.sharedInstance.startUpdatingLocation()
        //self.navigationItem.titleView = UIImageView(image: UIImage(named: Constants.ImageName.titleIcon)!)
        self.navigationItem.title = "Donors Search"
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func requestAlertMethod(userInfo: [NSObject : AnyObject]){
        
        let alertObject = UIAlertController(title: userInfo["gcm.notification.name"] as? String, message: userInfo["gcm.notification.comment"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
        let alertCancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            DataManager.sharedInstance.storeDatabase (userInfo,isAccepted: false, havingCallback: { (status) -> Void in
                if status{
                    print("storedsucessfully")
                }
            })
        })
        alertObject.addAction(alertCancelAction)
        let alertAcceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            //self.updateRequest(userInfo["gcm.notification.request_id"] as! String)
            DataManager.sharedInstance.storeDatabase (userInfo,isAccepted: true, havingCallback: { (status) -> Void in
                if status{
                    print("storedsucessfully")
                }
            })
        })
        alertObject.addAction(alertAcceptAction)
        self.presentViewController(alertObject, animated: true, completion: { () -> Void in
            // do something
        })
        
    }
    func initializeMapView() {
        self.activityIndicator.stopAnimating()
        let location: CLLocation! = self.defaultLocation
        let cameraPosition = GMSCameraPosition.cameraWithLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 16.0)
        let mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: cameraPosition)
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)
        mapView.delegate = self
        self.view = mapView
        self.mapView = mapView
        
        self.updateUserMarkerWithLocation(location)
        self.serachAndUpdateDonors(forLocation: location)
    }
    
    func requesterTableButtonAction(){
        let requesterViewController = self.storyboard?.instantiateViewControllerWithIdentifier("requesterIdentifier") as? RequesterTableViewController
        self.navigationController?.pushViewController(requesterViewController!, animated: true)
    }
    func donorTableButtonAction(){
        let requesterViewController = self.storyboard?.instantiateViewControllerWithIdentifier("donorIdentifier") as? DonorTableViewController
        self.navigationController?.pushViewController(requesterViewController!, animated: true)
    }
    
    func updateUserMarkerWithLocation(location: CLLocation) {
        if self.userMarker == nil {
            self.userMarker = GMSMarker()
        }
        userMarker?.position = location.coordinate
        userMarker?.icon = UIImage(named: Constants.ImageName.userLocation)
        userMarker?.map = self.mapView
    }
    
    func initializePointerForMap() {
        let pointerImage = UIImageView(image: UIImage(named: Constants.ImageName.bloodDrop)!)
        pointerImage.center = CGPointMake(UIScreen.mainScreen().bounds.width/2, UIScreen.mainScreen().bounds.height/2 - (22.0))
        pointerImage.frame.size = CGSize(width: 30.0, height: 30.0)
        pointerImage.layer.shadowColor = UIColor.blackColor().CGColor
        pointerImage.layer.shadowOpacity = 1.0
        pointerImage.layer.shadowRadius = 1.0
        pointerImage.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.view.addSubview(pointerImage)
        self.pointerPin = pointerImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: LocationManagerDelegates
    
    func locationManager(locationManager: CLLocationManager, didUpdateLocation location: CLLocation) {
        //print("LATITUDE: \(location.coordinate.latitude); LONGITUDE: \(location.coordinate.longitude); TIMESTAMP: \(location.timestamp)")
        self.defaultLocation = location
        self.updateUserMarkerWithLocation(location)
        if isFirstLoad {
            self.mapView?.moveCamera(GMSCameraUpdate.setTarget(location.coordinate))
            self.serachAndUpdateDonors(forLocation: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            self.isFirstLoad = false
        }
    }
    
    func locationmanager(locationManager: CLLocationManager, failedWithError error: NSError) {
        //print("LOCATION MANAGER FAILED: \(error)")
    }
    
    func locationManagerDidDenyAuthorization(locationManager: CLLocationManager) {
        //print("Location Manager did deny authorization")
    }
    
    func locationManager(locationManager: CLLocationManager, userUpdatesLocation location: CLLocation) -> Bool {
        return false
    }
    
    // MARK: GMSMapViewDelegates
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        //print("IDLE CAMERA COORDINATES; LAT: \(position.target.latitude), LONG: \(position.target.longitude)")
        let presentCamerIdleLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        guard let previousIdleLocation = self.previousIdleLocation else {
            self.previousIdleLocation = presentCamerIdleLocation
            return
        }
        if presentCamerIdleLocation.distanceFromLocation(previousIdleLocation) >= 50.0 {
            self.serachAndUpdateDonors(forLocation: CLLocation(latitude: position.target.latitude, longitude: position.target.longitude))
        }
        self.previousIdleLocation = presentCamerIdleLocation
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView) -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        guard let coordinates = userDefaults.objectForKey(lastUserLocationKey) as? NSDictionary, let mapView = self.mapView else {
            return false
        }
        let userLocation = CLLocation(latitude: coordinates.objectForKey("lat") as! Double, longitude: coordinates.objectForKey("long") as! Double)
        mapView.moveCamera(GMSCameraUpdate.setTarget(userLocation.coordinate))
        return true
    }
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        mapView.selectedMarker = marker
        return true
    }
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        var expectedDonor: Donor?
//        let userDefaults = NSUserDefaults.standardUserDefaults()
//        guard let userID = userDefaults.objectForKey("someUserKey") as? String else {
//            //show alert that user needs to log in
//            return
//        }
        expectedDonor = donorMarkerMapping[marker]
        /*for donor in self.donorsToDispaly {
            /*if marker.position.latitude == Double(donor.latitude) && marker.position.longitude == Double(donor.longitude) {
                expectedDonor = donor
                break
            }*/
            /*if marker == donor {
                expectedDonor = donor
            }*/
        }*/
        self.performSegueWithIdentifier(self.requestSegueIdentifier, sender: expectedDonor)
    }
    
    //MARK: FilterViewControllerDelegate
    
    func didSelectOptionsForFilter(filterArray: [String]) {
        self.filterArray = filterArray
        self.updateDonorsInMapViewForLocation(self.defaultLocation)
    }
    
    // MARK: Utility Methods
    
    func serachAndUpdateDonors(forLocation location: CLLocation) {
        if Reachability.isConnectedToNetwork() {
            self.activityIndicator.startAnimating()
            MapService.searchDonorsForLocation(location, havingCallback: { (donors) -> Void in
                self.activityIndicator.stopAnimating()
                self.refreshBarButton.enabled = true
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let donorArray = donors {
                    self.donors.removeAll()
                    if donorArray.count > 0 {
                        self.donors.removeAll()
                        for object in donorArray {
                            let donor = Donor()
                            if Int(object.valueForKey("is_donor") as! String) == 1 {
                                donor.id = object.valueForKey("id") as? String ?? ""
                                donor.bloodGroup = Utility.convertJsonToBloodGroup(object.valueForKey("blood_group") as? String ?? "")
                                donor.latitude = Double((object.valueForKey("latitude") as! String))!
                                donor.longitude = Double(object.valueForKey("longitude") as! String)!
                                if location.distanceFromLocation(CLLocation(latitude: donor.latitude, longitude: donor.longitude)) <= self.hundredKilometers {
                                    self.donors.append(donor)
                                }
                            }
                        }
                    }
                }
                // update mapView on main Queue
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // upadte  mapView
                    self.updateDonorsInMapViewForLocation(location)
                })
            })
        }
    }
    
    func updateDonorsInMapViewForLocation(location: CLLocation) {
        guard let mapView = self.mapView else {
            return
        }
        mapView.clear()
        self.donorsToDispaly = self.donors
        self.updateUserMarkerWithLocation(self.defaultLocation)
        if filterArray.count > 0 {
            // apply filter
            let predicate = NSPredicate(format: "%@ CONTAINS bloodGroup", self.filterArray)
            self.donorsToDispaly = self.donors.filter { (donor) -> Bool in
                predicate.evaluateWithObject(donor)
            }
        }
        for donor in self.donorsToDispaly {
            //print("DONOR: id=\(donor.id), bloodgropu=\(donor.bloodGroup), lat=\(donor.latitude), long:\(donor.longitude)")
            let donorMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: donor.latitude, longitude: donor.longitude))
            donorMarker.title = donor.bloodGroup
            donorMarker.icon = UIImage(named: Constants.ImageName.bloodDonor)
            donorMarker.snippet = "Request Donor (ID \(donor.id))"
            donorMarker.map = mapView
            donorMarkerMapping[donorMarker] = donor
        }
    }
    
    func showFilterViewController() {
        self.performSegueWithIdentifier(self.filterSegueIdentifier, sender: nil)
    }
    
    func refreshMapViewWithDonors() {
        guard let mapView = self.mapView else {
            return
        }
        self.refreshBarButton.enabled = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.serachAndUpdateDonors(forLocation: CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude))
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.requestSegueIdentifier {
            let requestVC = segue.destinationViewController as? RequestViewController
            requestVC?.donor = sender as? Donor
        }
        if segue.identifier == self.filterSegueIdentifier {
            let filterVC = segue.destinationViewController as? FilterViewController
            filterVC?.filterArray = self.filterArray
            filterVC?.delegate = self
        }
    }
}

class Donor: NSObject {
    // MARK: Properties
    var id: String = ""
    var bloodGroup: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}