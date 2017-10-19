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
 
    var chatroomIDs :[String] = []
    
    var dataSource: FUITableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //user is not logged in
        checkIfUserisLoggedIn()
        
        let query = Database.database().reference().child("chatrooms")
        dataSource = tableView.bind(to: query) { tableView, indexPath, snapshot in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellContact", for: indexPath)
            
            let dict = snapshot.value as? [String: Any]
            let name = dict?["name"] as? String
            
            cell.textLabel?.text = name
            
            return cell
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        guard let uid = AuthenticationManager.user()?.uid else {
//            return
//        }
//        
//        if editingStyle == .delete {
//            chatroomIDs.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            Database.database().reference().child("chatrooms").child().removeValue()
////            Database.database().reference().child("users").child(uid).child("chatrooms").child(chatrooms[indexPath.row].chatroomID).removeValue()
//        }
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
