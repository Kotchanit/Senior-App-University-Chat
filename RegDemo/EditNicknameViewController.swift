//
//  EditNicknameViewController.swift
//  RegDemo
//
//  Created by B13 on 11/9/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditNicknameViewController: UIViewController {

   
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet var activityindicater: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTap(#selector(self.dismissKeyboard))
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        // do aditional stuff
    }
    
    @IBAction func editNickname(_ sender: Any) {
        guard let uid = AuthenticationManager.user()?.uid else { return }
        
        let nickname = nicknameTextField.text
        let dataRef = Database.database().reference().child("users").child(uid).child("data")
        
        dataRef.child("nickname").setValue(nickname)
        
        activityindicater.startAnimating()
        //go back to the previous view controller
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
}
