//
//  RegisterViewController.swift
//  RegDemo
//
//  Created by B13 on 8/2/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var contactController : ContactViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        guard let username = usernameTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            showAlert(message: "Enter name, username and password")
            return
        }
        

        Auth.auth().createUser(withEmail: username, password: password, completion: { (user, error) in
            if user != nil {
                //sign in successful
                print("SUCESS")
                Helper.helper.switchToTabbarViewController()
            } else {
                if let myError = error?.localizedDescription {
                    print(myError)
                    
                } else {
                    print("ERROR")
                }
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let ref = Database.database().reference(fromURL: "https://regdemo-8a574.firebaseio.com/")
            let userReference = ref.child("users").child(uid)
            let values = ["name": name, "username": username]
            userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    
                    print(err!)
                    return
                }
                
                //self.contactController?.fetchUserAndSetupNavBarTitle()
                self.contactController?.navigationItem.title = values["name"] as String?
                self.dismiss(animated: true, completion: nil)
            })
            
        })
        
        
    }
    
}
