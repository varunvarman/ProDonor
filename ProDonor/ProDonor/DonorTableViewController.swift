//
//  DonorTableViewController.swift
//  ProDonor
//
//  Created by Vishnu on 02/09/16.
//  Copyright © 2016 DC. All rights reserved.
//

import UIKit
import CoreData

class DonorTableViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var donorTableViewList: UITableView!
    var donorObjects:NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Donors"
        fetchDataFromDatabase()
        donorTableViewList.delegate = self
        donorTableViewList.dataSource = self
        donorTableViewList.tableFooterView = UIView()
        let  nib1 = UINib(nibName: "DonorCustomCell", bundle: nil)
        donorTableViewList.registerNib(nib1, forCellReuseIdentifier: "donorCell")
    }
    
    
    func fetchDataFromDatabase(){
        DataManager.sharedInstance.fetchFromDatabase("DonorDetail", havingCallback: { (status,result) -> Void in
            if status{
                self.donorObjects = result! as NSArray
                self.donorTableViewList.reloadData()
            }
        })
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.translucent = false
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        tableView.rowHeight = 95
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.donorObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("donorCell", forIndexPath: indexPath) as! DonorCustomCell
        let donorObj = self.donorObjects[indexPath.row] as! DonorDetail
        cell.nameLabel.text = donorObj.username
        cell.mobileNumberLabel.text = donorObj.mobilenumber
        cell.callButton.tag = indexPath.row
        cell.callButton.addTarget(self, action: Selector("callButtonClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle  = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func callButtonClicked(sender: UIButton) {
        let tag = sender.tag
        let donor: DonorDetail = self.donorObjects[tag] as! DonorDetail
        //print("NUMBER: \(donor.mobilenumber)")
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "tel://\(donor.mobilenumber!)")!) {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(donor.mobilenumber!)")!)
        } else {
            // show alert
        }
        
    }
}
