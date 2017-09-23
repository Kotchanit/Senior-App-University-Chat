//
//  ViewController.swift
//  RegDemo
//
//  Created by Ant on 21/03/2017.
//  Copyright © 2017 Apptitude. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var contactController : ContactViewController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        loginButton.isEnabled = true
        
        if Auth.auth().currentUser?.uid != nil {
            
        }
    }
    
    
    
    @IBAction func loginPressed() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            showAlert(message: "Enter username and password")
            return
        }
        
        //loginButton.isEnabled = false
        
        //                API.login(username: username, password: password) { result in
        //                    self.loginButton.isEnabled = true
        //                    if case let .success(token) = result {
        //                        self.loginComplete(token: token)
        //                        TokenManager.set(token: token)
        //                    } else {
        //                        self.showAlert(message: result.error?.localizedDescription ?? "Unknown error")
        //                    }
        //                }

        Auth.auth().signIn(withEmail: username , password: password, completion: { (user, error) in
            if user != nil {
        
                self.performSegue(withIdentifier: "tabBar", sender: self)
            } else {
                
                if let myError = error?.localizedDescription {
                    print(myError)
                    
                } else {
                    print("ERROR")
                }
            }
            
            self.contactController?.fetchUserAndSetupNavBarTitle()
        
        })
        
    }
    
    
    
    func loginComplete(token: Token) {
        // Login anon to Firebase
        Helper.helper.loginAnonymously()
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "registerVC") as! RegisterViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = registerVC
    }
    
    
}

extension UIViewController {
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

