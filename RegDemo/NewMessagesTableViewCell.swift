//
//  NewMessagesTableViewCell.swift
//  RegDemo
//
//  Created by B13 on 10/16/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit

class NewMessagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var studentIDLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView?.layer.masksToBounds = false
        userImageView?.layer.cornerRadius = (userImageView?.frame.height)!/2
        userImageView?.clipsToBounds = true
        
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = UIColor(red:1.00, green:0.81, blue:0.46, alpha:1.0)
        selectedBackgroundView = myCustomSelectionColorView
    }
    
    override func prepareForReuse() {
        userImageView.image = nil
    }
}
