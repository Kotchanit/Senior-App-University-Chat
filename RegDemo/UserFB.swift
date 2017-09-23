//
//  UserFB.swift
//  RegDemo
//
//  Created by B13 on 8/21/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import FirebaseDatabase


class UserFB: NSObject {
    var id: String = ""
    var name: String = ""
    var username: String = ""
    
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? [String: Any] else {
            return nil
        }
        self.id = snapshot.key
        self.name = dictionary["name"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
    }

}
