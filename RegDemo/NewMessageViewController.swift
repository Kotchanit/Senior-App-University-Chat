//
//  NewMessageViewController.swift
//  RegDemo
//
//  Created by B13 on 8/10/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var users = [UserFB]() {
        didSet {
            displayedUsers = users.filter { $0.id != Auth.auth().currentUser!.uid }
        }
    }
    var displayedUsers = [UserFB]()
    var selectedUserIDs = [String]()
    var allname: [String] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedUser: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUsers()
        selectedUser.isEnabled = false
        selectedUser.title = "OK"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNM", for: indexPath)
        
        let user = displayedUsers[indexPath.row]
        cell.textLabel?.text = user.name
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = displayedUsers[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
            if let i = selectedUserIDs.index(of: user.id) {
                self.selectedUserIDs.remove(at: i)
            }
        } else {
            cell?.accessoryType = .checkmark
            self.selectedUserIDs.append(user.id)
        }
        
        if selectedUserIDs.count > 0 {
            selectedUser.isEnabled = true
            self.selectedUser.title = "OK(\(selectedUserIDs.count))"
        } else if selectedUserIDs.isEmpty == true {
            selectedUser.isEnabled = false
            selectedUser.title = "OK"
        }

    }

    func fetchUsers() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
  
            if let user = UserFB(snapshot: snapshot) {
                self.users.append(user)
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        
        }, withCancel: nil)
        
    }
    
    
    @IBAction func createNewChat(_ sender: Any) {
        let usersRef = Database.database().reference().child("users")
        let chatroomRef = Database.database().reference().child("chatrooms")
        let newChatroomKey = chatroomRef.childByAutoId().key
        let chatroomMembersRef = chatroomRef.child(newChatroomKey).child("members")
        let nameRef = chatroomRef.child(newChatroomKey).child("name")
        
        let allMemberIDs = selectedUserIDs + [Auth.auth().currentUser!.uid]
        
        // Filter all the users to just the selected users, and get their names only
        //check if user.id in allmembersID is true
        let selectedUsers = users.filter { allMemberIDs.contains($0.id) }
        //append name to names
        let names = selectedUsers.map { $0.name } //check n
        nameRef.setValue(names.joined(separator: ", "))

        // Adds all members to chatroom
        for userID in allMemberIDs {
            chatroomMembersRef.child(userID).setValue(true)
            usersRef.child(userID).child("chatrooms").child(newChatroomKey).setValue(true)
        }
        
        // Open the chatroom view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.chatroomID = newChatroomKey
        navigationController?.pushViewController(chatVC, animated: true)
        
        // Wait 1 second and then remove self from navigation stack
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let vcs = self.navigationController?.viewControllers {
                self.navigationController?.viewControllers = vcs.filter { $0 != self }
            }
        }
    }
}
