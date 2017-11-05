//
//  SettingViewController.swift
//  RegDemo
//
//  Created by B13 on 7/27/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import FirebaseAuth
import AlamofireImage
import Alamofire

class SettingViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var studentIDLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInfomation()
    }
    
    
    @IBAction func editNickname() {
        
    }
    
    func showInfomation () {
        if let token = AuthenticationManager.token(), let request = API.profileImageURLRequest(token: token) {
            profileImage.af_setImage(withURLRequest: request)
        }
        studentIDLabel.text = AuthenticationManager.user()?.uid
        nameLabel.text = AuthenticationManager.user()?.name
    }
    
    @IBAction func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        AuthenticationManager.clear()
        Helper.helper.switchToLoginViewController()
    }

    
}
