//
//  RequestViewController.swift
//  ProDonor
//
//  Created by Varun on 01/09/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
import UIKit

class RequestViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var donor: Donor?
    var loadingOverlay: UIView! = UIView(frame: UIScreen.mainScreen().bounds)
    var comment: String = " "
    
    @IBOutlet var bloodType: UILabel!
    @IBOutlet var commentField: UITextField!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var requestButton: UIButton!
    //MARK: Classes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Request Donor"
        self.cancelButton.addTarget(self, action: Selector("cancelRequest:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.requestButton.addTarget(self, action: Selector("sendRequestToDonor"), forControlEvents: UIControlEvents.TouchUpInside)
        self.cancelButton.layer.cornerRadius = 4.0
        self.requestButton.layer.cornerRadius = 4.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.hidesBackButton = true
        bloodType.text = donor?.bloodGroup.uppercaseString
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // do something
        textField.text = ""
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if ((textField.text?.isEmpty) == false) {
            self.comment = textField.text!
        }
    }
    
    func sendRequest(sender: UIButton) {
        self.view.endEditing(true)
        
    }
    
    func cancelRequest(sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func sendRequestToDonor() {
        self.view.endEditing(true)
        guard let userID = RegistrationService().getUserID() else {
            // log in to view service
            AlertController.showAlertControllerHaving(title: NSLocalizedString("AlertTitle", comment: ""), andMessage: NSLocalizedString("UserNotRegistered", comment: ""))
            return
        }
        guard let donor = self.donor else {
            return
        }
        if Reachability.isConnectedToNetwork() {
            self.showLoadingOverlay(show: true)
            self.comment = commentField.text!
            MapService.sendRequestToDonorHavingID(donorId: donor.id, withComment: self.comment, fromRequesteeID: userID, havingCallBack: { (error) -> Void in
                if error == nil {
                    AlertController.showAlertControllerHaving(title: NSLocalizedString("SuccessTitle", comment: ""), andMessage: NSLocalizedString("RequestSentSuccess", comment: ""))
                } else {
                    AlertController.showAlertControllerHaving(title: NSLocalizedString("AlertTitle", comment: ""), andMessage: NSLocalizedString("RequestSentError", comment: ""))
                }
                self.showLoadingOverlay(show: false)
            })
        } else {
            AlertController.showAlertControllerHaving(title: NSLocalizedString("AlertTitle", comment: ""), andMessage: NSLocalizedString("NetworkNotAvaliable", comment: ""))
        }
    }
    
//    func showAlertControllerHaving(title title: String, andMessage message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        let alertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.Default) { (action) -> Void in
//            // do nothing
//            self.navigationController?.popViewControllerAnimated(true)
//        }
//        alertController.addAction(alertAction)
//        self.presentViewController(alertController, animated: true) { () -> Void in
//        }
//    }
    
    //MARK: Utility Methods
    func showLoadingOverlay(show show: Bool) {
        self.loadingOverlay.backgroundColor = UIColor.whiteColor()
        self.loadingOverlay.alpha = 0.5
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: UIScreen.mainScreen().bounds.height/2)
        self.loadingOverlay.addSubview(self.activityIndicator)
        if show {
            self.activityIndicator.startAnimating()
            self.view.addSubview(self.loadingOverlay)
        } else {
            self.activityIndicator.stopAnimating()
            self.loadingOverlay.removeFromSuperview()
        }
    }
}
