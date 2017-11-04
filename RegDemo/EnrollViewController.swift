//
//  EnrollViewController.swift
//  RegDemo
//
//  Created by B13 on 10/7/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EnrollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedUser: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var chatrooms = [Chatroom]()
    
    var subjectID = 0
    var students: [Enroll] = [] {
        didSet {
            //เอา user ของตัวเองออก
            displayedUsers = students.filter { $0.studentID != AuthenticationManager.user()?.uid }
        }
    }
    
    var displayedUsers = [Enroll]()
    var selectedUserIDs = [String]()
    
    
    var year = 0
    var semester = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        if let token = AuthenticationManager.token() {
            API.enrolls(subject: subjectID, year: year, semester: semester, token: token, completion: { (result) in
                if case let .success(items) = result {
                    //print(items)
                    self.students = items
                    
                    self.tableView.reloadData()
                } else {
                    print("Error")
                    print(result.error!)
                }
            })

        }
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EnrollTableViewCell
        
        let item = displayedUsers[indexPath.row]
        cell.studentIDLabel.text = "\(item.studentID)"
        cell.nameLabel.text = item.name
        
        if let token = AuthenticationManager.token(), let request = API.userImageURLRequest(token: token, userID: item.studentID) {
            cell.userImageView.af_setImage(withURLRequest: request)
        }
        
        cell.accessoryType = selectedUserIDs.contains(item.studentID) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = displayedUsers[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
            if let i = selectedUserIDs.index(of: user.studentID) {
                self.selectedUserIDs.remove(at: i)
            }
        } else {
            cell?.accessoryType = .checkmark
            self.selectedUserIDs.append(user.studentID)
        }
        updateSelectedUser()
    }
    
    @IBAction func selectAllUser() {
        selectedUserIDs = displayedUsers.map { $0.studentID }
        tableView.reloadData()
        updateSelectedUser()
    }
    
    
    @IBAction func noneSelectUser() {
        selectedUserIDs = []
        tableView.reloadData()
        updateSelectedUser()
    }
    
    
    private func updateSelectedUser() {
        if selectedUserIDs.count > 0 {
            selectedUser.isEnabled = true
            self.selectedUser.title = "OK(\(selectedUserIDs.count))"
        } else if selectedUserIDs.isEmpty == true {
            selectedUser.isEnabled = false
            selectedUser.title = "OK"
        }
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
        let selectedUsers = students.filter { allMemberIDs.contains($0.studentID) }
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
