//
//  FilterViewController.swift
//  ProDonor
//
//  Created by Varun on 01/09/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
import UIKit

@objc protocol FilterViewControllerDelegate {
    optional func didSelectOptionsForFilter(filterArray: [String])
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    var filterArray: [String] = []
    var filterSet: NSMutableSet!
    var contentArray: [String] = []
    var delegate: FilterViewControllerDelegate?
    let cellIdentifier = "filterCell"
    @IBOutlet var filterTable: UITableView!
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterTable.bounces = false
        self.navigationItem.title = "Filter"
        let applyButton = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("didApplyFilter:"))
        self.navigationItem.rightBarButtonItem = applyButton
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("dismissViewController"))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.filterSet = NSMutableSet(array: self.filterArray)
        let pListPath = NSBundle.mainBundle().pathForResource("BloodType", ofType: ".plist")
        self.contentArray = NSArray(contentsOfFile: pListPath!) as! [String]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.hidesBackButton = true
    }
    
    //MARK: UITAbleViewDatasource & UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.filterTable.dequeueReusableCellWithIdentifier(self.cellIdentifier) as! FilterTableViewCell
        cell.bloodType.text = self.contentArray[indexPath.row]
        if self.filterSet.containsObject(self.contentArray[indexPath.row]) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // do somethng
        let type = self.contentArray[indexPath.row]
        if !self.filterSet.containsObject(type) {
            self.filterSet.addObject(type)
        } else {
            self.filterSet.removeObject(type)
        }
        self.filterTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    //MARK: Utility Methods
    
    func didApplyFilter(sender: UIBarButtonItem) {
        //do something
        if let delegate = self.delegate {
            self.filterArray = self.filterSet.allObjects as! [String]
            delegate.didSelectOptionsForFilter?(self.filterArray)
        }
        self.dismissViewController()
    }
    
    func dismissViewController() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}