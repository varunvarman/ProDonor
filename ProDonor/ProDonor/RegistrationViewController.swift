//
//  RegistrationViewController.swift
//  ProDonor
//
//  Created by Naveen on 31/08/16.
//  Copyright © 2016 DC. All rights reserved.
//

import UIKit
import DigitsKit
import CoreLocation

class RegistrationViewController: UIViewController {
    
    //MARK: Properties
    var bloodGroups: [String] = []
    var isDonor = true
    //MARK: Outlets
    @IBOutlet weak var bloodGroupPicker: UIPickerView! {
        didSet {
            bloodGroupPicker.dataSource = self
            bloodGroupPicker.delegate = self
        }
    }
    @IBOutlet weak var firstNameText: UITextField! {
        didSet {
            firstNameText.delegate = self
        }
    }
    @IBOutlet weak var lastNameText: UITextField! {
        didSet {
            lastNameText.delegate = self
        }
    }
    @IBOutlet weak var mobileNoText: UITextField! {
        didSet {
            mobileNoText.delegate = self
        }
    }
    //@IBOutlet weak var isDonor: UISwitch!
    @IBOutlet weak var firstNameMissing: UILabel!
    @IBOutlet weak var lastNameMissing: UILabel!
    @IBOutlet weak var mobileNoMissing: UILabel!
    //@IBOutlet weak var bloodGroupLabel: UILabel!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var spinnerBackground: UIView!
    @IBOutlet weak var donorBtn: UIButton!
    @IBOutlet weak var notADonorBtn: UIButton!
    
    
    //MARK: Variables
    let registrationService = RegistrationService()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var defaultLocation: CLLocation?
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let pListPath = NSBundle.mainBundle().pathForResource("BloodType", ofType: ".plist")
        self.bloodGroups = NSArray(contentsOfFile: pListPath!) as! [String]
        
        if isDonor {
            donorBtn.backgroundColor = UIColor.lightGrayColor()
            notADonorBtn.backgroundColor = UIColor.clearColor()
            bloodGroupPicker.hidden = false
        }
        else {
            donorBtn.backgroundColor = UIColor.clearColor()
            notADonorBtn.backgroundColor = UIColor.lightGrayColor()
            bloodGroupPicker.hidden = true
        }
        
        if let isRegistered = registrationService.isRegistered() {
            if !isRegistered {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadingComplete:", name: Constants.Notifications.LoadingComplete, object: nil)
                edgesForExtendedLayout = .None//prevent stackview from being displayed under navigation bar
                showActivityIndicator()
                if ((UIApplication.sharedApplication().delegate as! AppDelegate).loadingComplete == true) {
                    removeActivityIndicator()
                    startLocationUpdates()
                    
                }
            }
            else {
                performSegueWithIdentifier("showmapwithoutanimation", sender: self)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: IBActions
    @IBAction func skip(sender: AnyObject) {
        //performSegueWithIdentifier("showmap", sender: sender)
    }
    @IBAction func register(sender: UIButton) {
        print("selected row",self.bloodGroups[bloodGroupPicker.selectedRowInComponent(0)])
        if registrationService.getVerified() == 0 {
            let alert = UIAlertController(title: "Alert", message: "Please verify phone no", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
        else {
            if validateForm() {
                if let devicetoken = registrationService.getDeviceToken() {
                showActivityIndicator()
                let bloodgroup = self.bloodGroups[bloodGroupPicker.selectedRowInComponent(0)]
                    let name = firstNameText.text!.stringByTrimmingCharactersInSet(
                        NSCharacterSet.whitespaceAndNewlineCharacterSet()
                        ) + " " + lastNameText.text!.stringByTrimmingCharactersInSet(
                            NSCharacterSet.whitespaceAndNewlineCharacterSet()
                    )
                print("\(name) \(bloodgroup) selected blood group \(Utility.convertBloodGroupForJson(bloodgroup))")
                    let parameters:[String:AnyObject] = ["devicetoken":devicetoken, "name":name,"mobileno":mobileNoText.text!,"isDonor":isDonor ? "true" : "false","bloodgroup":Utility.convertBloodGroupForJson(bloodgroup)]
                    print("is donor \(parameters["isDonor"])")
                    registrationService.updateUser(parameters) {
                    [unowned self] response in
                        print("registration complete")
                        self.removeActivityIndicator()
                        self.performSegueWithIdentifier("showmap", sender: sender)
                        self.registrationService.saveRegistration()
                    }
                }
                else {
                    print("registration failed please try again later")
                }
            }
        }
    }

    @IBAction func didTapVerifyButton(sender: UIButton) {
        let digits = Digits.sharedInstance()
        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
        configuration.appearance = DGTAppearance()
        configuration.phoneNumber = mobileNoText.text
        configuration.appearance.backgroundColor = UIColor.blackColor()
        configuration.appearance.accentColor = UIColor.redColor()
        configuration.appearance.headerFont = UIFont(name: "Arial", size: 18)
        configuration.appearance.labelFont = UIFont(name: "Arial", size: 16)
        configuration.appearance.bodyFont = UIFont(name: "Arial", size: 16)
        digits.authenticateWithViewController(nil, configuration: configuration) { session, error in
            if(session != nil){
                dispatch_async(dispatch_get_main_queue(), {
                    print( "Phone number: \(session!.phoneNumber)")
                    self.registrationService.setVerified(1)
                    self.registrationService.updateUserVerified()
                    self.disablePhoneNoAndVerifyButton()
                })
            }else{
                print("Authentication error \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func donorSelectionChanged(sender: UISwitch) {
        if sender.on {
            bloodGroupPicker.hidden = false
            //bloodGroupLabel.hidden = false
        }
        else {
            bloodGroupPicker.hidden = true
            //bloodGroupLabel.hidden = true
        }
    }
    
    @IBAction func donor(sender: UIButton) {
        isDonor = true
        donorBtn.backgroundColor = UIColor.lightGrayColor()
        notADonorBtn.backgroundColor = UIColor.clearColor()
        bloodGroupPicker.hidden = false
        
    }
    
    @IBAction func notADonor(sender: UIButton) {
        isDonor = false
        donorBtn.backgroundColor = UIColor.clearColor()
        notADonorBtn.backgroundColor = UIColor.lightGrayColor()
        bloodGroupPicker.hidden = true
    }
    
    //MARK: Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showmap" {
            if let dvc = segue.destinationViewController as? MapViewController {
                if defaultLocation != nil {
                    dvc.defaultLocation = defaultLocation!
                }
            }
        }
    }
    func startLocationUpdates() {
        LocationManager.sharedInstance.delegate = self
        LocationManager.sharedInstance.startUpdatingLocation()

    }
    func showActivityIndicator() {
        spinnerBackground.hidden = false
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)
    }
    
    func removeActivityIndicator() {
        spinnerBackground.hidden = true
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    func disablePhoneNoAndVerifyButton() {
        self.mobileNoText.enabled = false
        self.mobileNoText.backgroundColor = UIColor.lightGrayColor()
        self.verifyBtn.enabled = false
        self.verifyBtn.setTitle("verified", forState: .Normal)
        self.verifyBtn.titleLabel?.textColor = UIColor.lightGrayColor()
    }
    
    func loadingComplete(notification:NSNotification) {
        removeActivityIndicator()
        startLocationUpdates()
    }
    
    func validateForm() -> Bool {
        var formValidated = true
        if firstNameText.text?.characters.count <= 0 {
            firstNameMissing.hidden = false
            formValidated = false
        }
        else {
            firstNameMissing.hidden = true
        }
        if lastNameText.text?.characters.count <= 0 {
            lastNameMissing.hidden = false
            formValidated = false
        }
        else {
            lastNameMissing.hidden = true
        }
        if mobileNoText.text?.characters.count <= 0 {
            mobileNoMissing.hidden = false
            formValidated = false
        }
        else {
            mobileNoMissing.hidden = true
        }
        
        return formValidated
    }

}

//MARK: UIPickerViewDataSource
extension RegistrationViewController: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.bloodGroups.count
    }
}


//MARK: UIPickerViewDelegate
extension RegistrationViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.bloodGroups[row]
    }
}

//MARK: UITextFieldDelegate 
extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RegistrationViewController: LocationManagerDelegate {
    func locationManager(locationManager: CLLocationManager, didUpdateLocation location: CLLocation) {
        defaultLocation = location
        if let userID = registrationService.getUserID() {
            MapService.updateDonorLocation(location, havingID: userID, withCallback: { (error) -> Void in
                if error == nil {
                    // update location success
                } else {
                    // update location failure
                }
            })
        }
    }
}
