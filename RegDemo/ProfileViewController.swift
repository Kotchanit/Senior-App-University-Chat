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

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var facultyLabel: UILabel!
    @IBOutlet weak var programLabel: UILabel!
    @IBOutlet weak var gpaLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInfomation()
        print(AuthenticationManager.user()?.latestGPA)
    }
    
    
    @IBAction func editNickname() {
        
    }
    
    func showInfomation () {
        if let token = AuthenticationManager.token(), let request = API.profileImageURLRequest(token: token) {
            profileImage.af_setImage(withURLRequest: request)
        }
        usernameLabel.text = AuthenticationManager.user()?.uid
        nameLabel.text = AuthenticationManager.user()?.name
        statusLabel.text = AuthenticationManager.user()?.status
        facultyLabel.text = AuthenticationManager.user()?.status
        programLabel.text = AuthenticationManager.user()?.programName
        gpaLabel.text = "\(AuthenticationManager.user()?.latestGPA)"
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

