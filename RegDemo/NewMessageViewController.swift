//
//  NewMessageViewController.swift
//  RegDemo
//
//  Created by B13 on 8/10/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var users = [User]() {
        didSet {
            //get current user out
            displayedUsers = users.filter { $0.uid != AuthenticationManager.user()?.uid }
        }
    }
    
    var searchKeyword: String? = nil {
        didSet {
            if let keyword = searchKeyword, keyword != "" {
                displayedUsers = users.filter { $0.uid != AuthenticationManager.user()?.uid && $0.name.contains(keyword) }
            }
            else {
                displayedUsers = users.filter { $0.uid != AuthenticationManager.user()?.uid }
            }
        }
    }
    
    var displayedUsers = [User]()
    var currentUser = [User]()
    var selectedUserIDs = [String]()
    var allname: [String] = []
    var searchController = UISearchController()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedUser: UIBarButtonItem!
    
    var nickname = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUsers()
        selectedUser.isEnabled = false
        selectedUser.title = "OK"
        
        let point = CGPoint(x: 0, y:(self.navigationController?.navigationBar.frame.size.height)!)
        
        self.tableView.setContentOffset(point, animated: true)
        self.hideKeyboardOnTap(#selector(self.dismissKeyboard))
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        // do aditional stuff
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNM", for: indexPath) as! NewMessagesTableViewCell
        let user = displayedUsers[indexPath.row]
    
        cell.nameLabel.text = user.name
        cell.studentIDLabel.text = "\(user.username)"
        cell.accessoryType = selectedUserIDs.contains(user.uid) ? .checkmark : .none
        
        if let token = AuthenticationManager.token(), let request = API.userImageURLRequest(token: token, userID: user.username) {
            cell.userImageView.af_setImage(withURLRequest: request)
        }
        
        // cell.userImageView?.layer.borderWidth = 1
        cell.userImageView?.layer.masksToBounds = false
        //cell.userImageView?.layer.borderColor = UIColor.white.cgColor
        cell.userImageView?.layer.cornerRadius = (cell.userImageView?.frame.height)!/2
        cell.userImageView?.clipsToBounds = true
        
        //        cell.userImageView?.layer.cornerRadius = (cell.userImageView?.frame.size.width)! / 2
        //        cell.userImageView?.layer.masksToBounds = true
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchKeyword = searchText.isEmpty ? nil : searchText
        tableView.reloadData()
    }

    //fetch users from firebase
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
        let allMemberIDs = selectedUserIDs + [AuthenticationManager.user()!.uid]
        let chatroomRef = Database.database().reference().child("chatrooms")
        
        getChatroomKey(chatroomRef: chatroomRef, for: allMemberIDs) { (key) in
            
            let chatroomKey = key ?? self.newChatroom(chatroomRef: chatroomRef, memberIDs: allMemberIDs)
            
            // Open the chatroom view
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
            chatVC.chatroomID = chatroomKey
            self.navigationController?.pushViewController(chatVC, animated: true)
            
            // Wait 1 second and then remove self from navigation stack
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let vcs = self.navigationController?.viewControllers {
                    self.navigationController?.viewControllers = vcs.filter { $0 != self }
                }
            }
        }

    }
    
    private func getChatroomKey(chatroomRef: DatabaseReference, for memberIDs: [String], completion: @escaping (String?) -> ()) {
        let membersRaw = memberIDs.sorted().joined(separator: ",")
        let query = chatroomRef.queryOrdered(byChild: "membersRaw").queryEqual(toValue: membersRaw)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if let chatroom = snapshot.children.nextObject() as? DataSnapshot {
                let uid = AuthenticationManager.user()!.uid
                let databaseRef = Database.database().reference()
                databaseRef.child("chatrooms").child(chatroom.key).child("members").child(uid).setValue(true)
                databaseRef.child("users").child(uid).child("chatrooms").child(chatroom.key).setValue(true)
                completion(chatroom.key)
            }
            else {
                completion(nil)
            }
        })
    }
    
    private func newChatroom(chatroomRef: DatabaseReference, memberIDs: [String]) -> String {
        let usersRef = Database.database().reference().child("users")
        let newChatroomKey = chatroomRef.childByAutoId().key
        let chatroomMembersRef = chatroomRef.child(newChatroomKey).child("members")
        let nameRef = chatroomRef.child(newChatroomKey).child("name")
        
        // Filter all the users to just the selected users, and get their names only
        //check if user.id in allmembersID is true
        let selectedUsers = users.filter { memberIDs.contains($0.uid) }
        //append name to names
        let names = selectedUsers.map { $0.name } //check n
        nameRef.setValue(names.joined(separator: ", "))
        
        // Adds all members to chatroom
        for userID in memberIDs {
            chatroomMembersRef.child(userID).setValue(true)
            usersRef.child(userID).child("chatrooms").child(newChatroomKey).setValue(true)
        }
        
        // Add membersRaw
        let membersRaw = memberIDs.sorted().joined(separator: ",")
        chatroomRef.child(newChatroomKey).child("membersRaw").setValue(membersRaw)
        
        return newChatroomKey
    }
}

