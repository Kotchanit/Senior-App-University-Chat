//
//  HomeViewController.swift
//  RegDemo
//
//  Created by B13 on 6/22/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import FirebaseDatabase


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileView: UIView!
    
    
    
    var subjectItems: [Subject] = []
    var nickname = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        if let token = AuthenticationManager.token() {
            API.subjects(token: token, completion: { (result) in
                if case let .success(items) = result {
                    self.subjectItems = items
                    self.tableView.reloadData()
                } else {
                    print("Error")
                    print(result.error!)
                }
            })
        }
        profileImageView.image = UIImage(named: "user")
        self.nameLabel.text = AuthenticationManager.user()?.name
        profileView.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        showInfomation()
    }
    

    
    func showInfomation () {
        guard let uid = AuthenticationManager.user()?.uid else { return }
        
        Database.database().reference().child("users").child(uid).child("data").child("nickname").observeSingleEvent(of: .value, with: { (snapshot) in
            if let nicknamesanpshot = snapshot.value as? String {
                self.nickname = nicknamesanpshot
                if self.nickname == "" {
                    self.nameLabel.text = AuthenticationManager.user()?.name
                } else {
                    self.nameLabel.text = self.nickname
                }
            }
        })
        
        if let token = AuthenticationManager.token(), let request = API.profileImageURLRequest(token: token) {
            profileImageView.af_setImage(withURLRequest: request)
            
        }
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
        usernameLabel.text = AuthenticationManager.user()?.uid
        tableView.reloadData()
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = subjectItems[indexPath.row]
        cell.textLabel?.text = item.nameEN
        
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = UIColor(red:1.00, green:0.81, blue:0.46, alpha:1.0)
        cell.selectedBackgroundView = myCustomSelectionColorView

        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let enrollController = segue.destination as? EnrollViewController
            enrollController?.subjectID = subjectItems[indexPath.row].subjectID
            enrollController?.year = subjectItems[indexPath.row].year
            enrollController?.semester = subjectItems[indexPath.row].semester
            enrollController?.chatname = subjectItems[indexPath.row].nameEN
        }
    }
    
}




