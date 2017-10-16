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

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
 
    
    var chatroomIDs :[String] = []
    var chatrooms = [Chatroom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //user is not logged in
        checkIfUserisLoggedIn()
       
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatroomIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellContact", for: indexPath)
        
        cell.textLabel?.text = chatroomIDs[indexPath.row]
        //cell.detailTextLabel?.text = "\(members.count)"
    
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
//    {
//        return true
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
//    {
//        guard let uid = AuthenticationManager.user()?.uid else {
//            
//            return
//        }
//        
//        if editingStyle == .delete {
//            chatroomIDs.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
////            Database.database().reference().child("chatrooms").child(chatroomIDs[indexPath.row]).removeValue()
////            Database.database().reference().child("users").child(uid).child("chatrooms").child(chatroomIDs[indexPath.row]).removeValue()
//        }
//    }
    
    
    func fetchChatrooms() {
        Database.database().reference().child("chatrooms").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {
                return
            }
            
            var chatrooms = [Chatroom]()
            for (chatroomID, object) in dictionary {
                if let dict = object as? [String: Any], let name = dict["name"] as? String {
                    let chatroom = Chatroom(chatroomID: chatroomID, name: name)
                    chatrooms.append(chatroom)
                }
            }
            self.chatrooms = chatrooms
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let chatController = segue.destination as? ChatViewController
            chatController?.chatroomID = chatroomIDs[indexPath.row]
            
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
