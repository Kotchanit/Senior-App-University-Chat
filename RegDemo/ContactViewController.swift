//
//  ContactViewController.swift
//  RegDemo
//
//  Created by B13 on 7/20/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseUI

class ContactViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: EditableTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //user is not logged in
        checkIfUserisLoggedIn()
        
        guard let uid = AuthenticationManager.user()?.uid else {
            return
        }
        
        // Get the chatrooms that the current user is a member of chat
        let query = Database.database().reference().child("chatrooms")
            .queryOrdered(byChild: "members/\(uid)").queryEqual(toValue: true)
        
        dataSource = tableView.bind(to: query, populateCell: { (tableView, indexPath, snapshot) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellContact", for: indexPath) as! ContactTableViewCell
            
            let dict = snapshot.value as? [String: Any]
            let name = dict?["name"] as? String
            let latestMessage = dict?["lastest_message"] as? String
            let latestMessageTimestamp = dict?["lastest_message_timestamp"] as? String
            
            cell.chatNameLabel.text = name
            cell.latestMessageLabel.text = latestMessage
            cell.timeLabel.text = latestMessageTimestamp
            
            return cell
        }, commitEdit: { (tableView, editingStyle, indexPath, snapshot) in
            let chatroomID = snapshot.key
            guard let uid = AuthenticationManager.user()?.uid else { return }
            
            if editingStyle == .delete {
                let databaseRef = Database.database().reference()
                databaseRef.child("chatrooms").child(chatroomID).child("members").child(uid).removeValue()
                databaseRef.child("users").child(uid).child("chatrooms").child(chatroomID).removeValue()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let chatController = segue.destination as? ChatViewController
            chatController?.chatroomID = dataSource!.snapshot(at: indexPath.row).key
        }
    }
    
    func checkIfUserisLoggedIn() {
        if AuthenticationManager.user()?.uid == nil {
            perform(#selector(logout), with: nil, afterDelay: 0)
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        AuthenticationManager.clear()
        Helper.helper.switchToLoginViewController()
    }
    
    
}
