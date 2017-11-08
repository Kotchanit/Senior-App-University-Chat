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
    
    override func prepareForReuse() {
        userImageView.image = nil
    }
}
