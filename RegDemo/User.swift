//
//  User.swift
//  RegDemo
//
//  Created by Ant on 21/03/2017.
//  Copyright © 2017 Apptitude. All rights reserved.
//

import Foundation

struct User {
    let username: String
    let name: String
    let status: String
    let departmentName: String
    let facultyName: String
    let programName: String?
    let latestGPA: Float?
    //    var avatarImage: JSQMessagesAvatarImage?
    
    var uid: String {
        return username
    }
    
    init(username: String, name: String, status: String, departmentName: String, facultyName: String, programName: String? = nil, latestGPA: Float? = nil) {
        self.username = username
        self.name = name
        self.status = status
        self.departmentName = departmentName
        self.facultyName = facultyName
        self.programName = programName
        self.latestGPA = latestGPA
        //        self.avatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    }
}

