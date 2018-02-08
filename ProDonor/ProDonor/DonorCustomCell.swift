//
//  DonorCustomCell.swift
//  ProDonor
//
//  Created by Vishnu on 02/09/16.
//  Copyright © 2016 DC. All rights reserved.
//

import UIKit
class DonorCustomCell:UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.callButton.layer.cornerRadius = self.callButton.frame.size.width/2
        self.callButton.layer.borderWidth = 1.5
        self.callButton.layer.borderColor = UIColor(red: 215.0/255.0, green: 45.0/255.0, blue: 38.0/255.0, alpha: 1.0).CGColor
    }
    
    @IBOutlet var callButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
}