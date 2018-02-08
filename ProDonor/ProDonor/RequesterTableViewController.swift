//
//  TableViewController.swift
//  ProDonor
//
//  Created by Vishnu on 02/09/16.
//  Copyright © 2016 DC. All rights reserved.
//

import UIKit
import CoreData

class RequesterTableViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableViewList: UITableView!
    var requesterObjects:NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Requests"
        fetchDataFromDatabase()
        tableViewList.delegate = self
        tableViewList.dataSource = self
        tableViewList.tableFooterView = UIView()
        let  nib1 = UINib(nibName: "RequesterCustomCell", bundle: nil)
        tableViewList.registerNib(nib1, forCellReuseIdentifier: "cell")
    }
    
    
    
    func fetchDataFromDatabase(){
        DataManager.sharedInstance.fetchFromDatabase("Requester", havingCallback: { (status,result) -> Void in
            if status{
                self.requesterObjects = result! as NSArray
                self.tableViewList.reloadData()
            }
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.translucent = false
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        tableView.rowHeight = 110
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requesterObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RequesterCustomCell
        let requesterObj = self.requesterObjects[indexPath.row] as! Requester
        cell.nameLabel.text = requesterObj.username
        cell.commentLabel.text = requesterObj.comment
        print(String(requesterObj.isAccepted!))
        if requesterObj.isAccepted! as Bool{
            cell.acceptedLabel.text = "ACCEPTED"
            cell.acceptedLabel.textColor = UIColor(red: 67.0/255.0, green: 178.0/255.0, blue: 57.0/255.0, alpha: 1.0)
        }else{
            cell.acceptedLabel.text = "REJECTED"
            cell.acceptedLabel.textColor = UIColor(red: 215.0/255.0, green: 45.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        }
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle  = UITableViewCellSelectionStyle.None
        return cell
    }
    
    
    
    
    
    
    
    
    
    
}
