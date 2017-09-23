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
    
    func checkIfUserisLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(logout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
 
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                if let dict = dictionary["chatrooms"] as? [String: Any] {
                    self.chatroomIDs = [String](dict.keys)
                    //self.getMembers()
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
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
    }
    
    @IBAction func newMessage(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newMessageVC = storyboard.instantiateViewController(withIdentifier: "nmView")
        present(newMessageVC, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let chatController = segue.destination as? ChatViewController
            chatController?.chatroomID = chatroomIDs[indexPath.row]
            
        }
    }
 
}
