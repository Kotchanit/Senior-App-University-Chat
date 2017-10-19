//
//  EditViewController.swift
//  RegDemo
//
//  Created by B13 on 10/9/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditViewController: UIViewController {

    
    @IBOutlet weak var chatNameTextField: UITextField!
    
    var chatroomID = ""
    
    @IBAction func changeNameofChat(_ sender: Any) {
        let chatname = chatNameTextField.text
        let dataRef = Database.database().reference().child("chatrooms").child(chatroomID).child("name")
        dataRef.setValue(chatname)
        
        //go back to the previous view controller
        let _ = navigationController?.popViewController(animated: true)
    }
    
}
