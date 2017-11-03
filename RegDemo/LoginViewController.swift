//
//  ViewController.swift
//  RegDemo
//
//  Created by Ant on 21/03/2017.
//  Copyright © 2017 Apptitude. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    let fcmtoken = Messaging.messaging().fcmToken
    
    var contactController : ContactViewController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        loginButton.isEnabled = true
        
        usernameTextField.text = "57313783"
        passwordTextField.text = "1234"
        
        print("FCM token: \(fcmtoken ?? "")")
        
        if Auth.auth().currentUser?.uid != nil {
            
        }
    }
    
    
    @IBAction func loginPressed() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            showAlert(message: "Enter username and password")
            return
        }
        
        loginButton.isEnabled = false
        
        API.login(username: username, password: password) { result in
            if case let .success(token) = result {
                AuthenticationManager.set(token: token)
                self.loginComplete(token: token)
            } else {
                self.loginButton.isEnabled = true
                self.showAlert(message: result.error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func loginComplete(token: Token) {
        API.profile(token: token) { result in
            self.loginButton.isEnabled = true
            if case let .success(user) = result {
                AuthenticationManager.set(user: user)
                // Login anon to Firebase
                Helper.helper.loginAnonymously() { success in
                    if success {
                        let userData = ["name": user.name, "status": user.status, "departmentName": user.departmentName, "facultyName": user.facultyName, "programName" : user.programName ]
                        
                        let dataRef = Database.database().reference().child("users").child(user.uid).child("data")
                        dataRef.setValue(userData)
                        dataRef.child("fcmtoken").setValue(self.fcmtoken)
                    }
                    else {
                        self.showAlert(message: "Could not connect to Firebase")
                    }
                }
            }
            else {
                self.showAlert(message: result.error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
}

extension UIViewController {
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

