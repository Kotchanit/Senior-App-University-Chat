//
//  Enroll.swift
//  RegDemo
//
//  Created by B13 on 10/7/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import Foundation

struct Enroll {
    let studentID: String
    let firstnameEN: String
    let lastnameEN: String
    
    var nameEN: String {
        return firstnameEN.capitalized + " " + lastnameEN.capitalized
    }
}
