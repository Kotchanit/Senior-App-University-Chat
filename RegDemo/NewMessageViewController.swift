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
    
    
    var users = [User]() {
        didSet {
            //เอา user ของตัวเองออก
            displayedUsers = users.filter { $0.uid != AuthenticationManager.user()?.uid }
        }
    }
    var displayedUsers = [User]()
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
            if let i = selectedUserIDs.index(of: user.uid) {
                self.selectedUserIDs.remove(at: i)
            }
        } else {
            cell?.accessoryType = .checkmark
            self.selectedUserIDs.append(user.uid)
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
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {
                return
            }
            
            var users = [User]()
            for (uid, object) in dictionary {
                if let dict = object as? [String: Any], let userDict = dict["data"] as? [String: Any], let name = userDict["name"] as? String, let status = userDict["status"] as? String, let departmentName = userDict["departmentName"] as? String, let facultyName = userDict["facultyName"] as? String, let programName = userDict["programName"] as? String {
                    let user = User(username: uid, name: name, status: status, departmentName: departmentName, facultyName: facultyName, programName: programName)
                    users.append(user)
                }
            }
            self.users = users
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        })
    }
    
    
    @IBAction func createNewChat(_ sender: Any) {
        let usersRef = Database.database().reference().child("users")
        let chatroomRef = Database.database().reference().child("chatrooms")
        let newChatroomKey = chatroomRef.childByAutoId().key
        let chatroomMembersRef = chatroomRef.child(newChatroomKey).child("members")
        let nameRef = chatroomRef.child(newChatroomKey).child("name")
        
        let allMemberIDs = selectedUserIDs + [AuthenticationManager.user()!.uid]
        
        // Filter all the users to just the selected users, and get their names only
        //check if user.id in allmembersID is true
        let selectedUsers = users.filter { allMemberIDs.contains($0.uid) }
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
