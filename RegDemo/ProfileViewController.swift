//
//  ProfileViewController.swift
//  RegDemo
//
//  Created by Ant on 21/03/2017.
//  Copyright © 2017 Apptitude. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class ProfileViewController: UIViewController {
    
    var token: Token?
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var courseDepartmentLabel: UILabel!
    @IBOutlet var facultyLabel: UILabel!
    @IBOutlet var gpaLabel: UILabel!
    @IBOutlet var subjectButtton: UIButton!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let token = token {
            //print("Token: \(token.value)")
            
            API.profile(token: token) { result in
                if case let .success(user) = result {
                    self.bind(user: user)
                }
                else {
                    self.showAlert(message: result.error?.localizedDescription ?? "Unknown error")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func bind(user: User) {
        nameLabel.text = user.name
        courseDepartmentLabel.text = user.status == "student" ? user.programName : user.departmentName
        facultyLabel.text = user.facultyName
        
        if user.status == "student" {
            if let gpa = user.latestGPA {
                gpaLabel.text = String(format: "%.2f", gpa)
            }
            else {
                gpaLabel.text = "-"
            }
        }
        else {
            gpaLabel.text = "teacher"
        }
        
        if let request = API.profileImageURLRequest(token: token!) {
            profileImageView.af_setImage(withURLRequest: request)
        }
        else {
            profileImageView.image = nil
        }
    }
    
    @IBAction func logoutPressed() {
        dismiss(animated: true, completion: nil)
    }

}
