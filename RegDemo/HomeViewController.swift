//
//  HomeViewController.swift
//  RegDemo
//
//  Created by B13 on 6/22/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var subjectItems: [Subject] = []
    var year = 2560
    var semester = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let token = AuthenticationManager.token() {
            API.subjects(year: year, semester: semester, token: token, completion: { (result) in
                if case let .success(items) = result {
                    self.subjectItems = items
                    self.tableView.reloadData()
                } else {
                    print("Error")
                    print(result.error!)
                }
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = subjectItems[indexPath.row]
        cell.textLabel?.text = item.nameTH
        return cell
    }

}
