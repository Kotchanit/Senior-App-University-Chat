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
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var facultyLabel: UILabel!
    @IBOutlet weak var programLabel: UILabel!
    @IBOutlet weak var gpaLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var editNickname: UIButton!
    
    var nickname = ""
    override func viewDidLoad() {
        editNickname.semanticContentAttribute = .forceRightToLeft
        editNickname.setTitle("Edit Nickname ", for: .normal)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showInfomation()
    }
    
    
    func showInfomation () {
        guard let uid = AuthenticationManager.user()?.uid else { return }

        Database.database().reference().child("users").child(uid).child("data").child("nickname").observeSingleEvent(of: .value, with: { (snapshot) in
            if let nicknamesanpshot = snapshot.value as? String {
                self.nickname = nicknamesanpshot
            }
        })
       
        if nickname == "" {
            self.nicknameLabel.text = AuthenticationManager.user()?.name
        } else {
            self.nicknameLabel.text = nickname
        }
        
        if let token = AuthenticationManager.token(), let request = API.profileImageURLRequest(token: token) {
            profileImage.af_setImage(withURLRequest: request)
        }
        usernameLabel.text = AuthenticationManager.user()?.uid
        nameLabel.text = AuthenticationManager.user()?.name
        statusLabel.text = AuthenticationManager.user()?.status
        facultyLabel.text = AuthenticationManager.user()?.facultyName
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

