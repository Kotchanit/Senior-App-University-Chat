//
//  EnrollViewController.swift
//  RegDemo
//
//  Created by B13 on 10/7/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit

class EnrollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var subjectID = 0
    var studentIDs: [Enroll] = []
    
    var year = 0
    var semester = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let token = AuthenticationManager.token() {
            API.enrolls(subject: subjectID, year: year, semester: semester, token: token, completion: { (result) in
                if case let .success(items) = result {
                    self.studentIDs = items
                    self.tableView.reloadData()
                } else {
                    print("Error")
                    print(result.error!)
                }
            })

        }
        
        print("********")
        print(studentIDs)
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = studentIDs[indexPath.row]
        cell.textLabel?.text = item.name
        
        print(item)
        
        return cell
    }
    

}
