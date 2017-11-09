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

    @IBAction func editNickname(_ sender: Any) {
        guard let uid = AuthenticationManager.user()?.uid else { return }
        
        let nickname = nicknameTextField.text
        let dataRef = Database.database().reference().child("users").child(uid).child("data")
        
        dataRef.child("nickname").setValue(nickname)
        
        //go back to the previous view controller
        let _ = navigationController?.popViewController(animated: true)
    }
    
}
