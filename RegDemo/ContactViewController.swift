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
    
    var chatroomIDs: [String] = []
    
    var dataSource: EditableTableViewDataSource?
    
    var allmembers: [String] = []
    
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
            
            cell.chatNameLabel.text = name
            
            return cell
        }, commitEdit: { (tableView, editingStyle, indexPath) in
            let chatroomID = self.chatroomIDs[indexPath.row]
            guard let uid = AuthenticationManager.user()?.uid else { return }
            
            if editingStyle == .delete {
                self.chatroomIDs.remove(at: indexPath.row)
                Database.database().reference().child("chatrooms").child(chatroomID).child("members").child(uid).removeValue()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
//    private func prepareChatImage(with id: String) {
//        let chatName = ""
//
//        Database.database().reference().child("chatrooms").child().child("name").observeSingleEvent(of: .value, with: { (snapshot) in
//            if let name = snapshot.value as? String {
//                self.senderDisplayName = name
//            }
//        })
//
//        let firstChar =
//        if (self.avatars[id] == nil) {
//            let avartarImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "\(firstChar!)" , backgroundColor: UIColor.groupTableViewBackground, textColor: UIColor.lightGray, font: UIFont.systemFont(ofSize: 17), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//            self.avatars[id] = avartarImage
//        }
//
//        return self.avatars[id]
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let chatController = segue.destination as? ChatViewController
            chatController?.chatroomID = dataSource!.snapshot(at: indexPath.row).key
        }
    }
    
    func checkIfUserisLoggedIn() {
        if AuthenticationManager.user()?.uid == nil {
            perform(#selector(logout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = AuthenticationManager.user()?.uid else {
            
            return
        }
        
        Database.database().reference().child("users").child(uid).child("data").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                self.tableView.reloadData()
            }
        }, withCancel: nil)
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                if let dict = dictionary["chatrooms"] as? [String: Any] {
                    self.chatroomIDs = [String](dict.keys)
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
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
