//
//  TokenManager.swift
//  RegDemo
//
//  Created by B13 on 7/19/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import Foundation

class AuthenticationManager {
    
    private static let keyAccessToken = "AccessToken"
    private static let keyUsername = "Username"
    private static let keyname = "name"
    private static let keystatus = "status"
    private static let keydepartmentName = "departmentName"
    private static let keyfacultyName = "facultyName"
    private static let keyprogramName = "programName"
    private static let keylatestGPA = "latestGPA"
    
    static func token() -> Token? {
        if let tokenString = UserDefaults.standard.string(forKey: keyAccessToken) {
            return Token(value: tokenString)
        }
        return nil
    }
    
    static func set(token:Token) {
        UserDefaults.standard.set(token.value, forKey: keyAccessToken)
    }
    
    static func user() -> User? {
        let ud = UserDefaults.standard
        if let username = ud.string(forKey: keyUsername), let name = ud.string(forKey: keyname), let status = ud.string(forKey: keystatus), let departmentName = ud.string(forKey: keydepartmentName), let facultyName = ud.string(forKey: keyfacultyName), let programName = ud.string(forKey: keyprogramName) {
            let latestGPA = ud.float(forKey: keylatestGPA)
            return User(username: username, name: name , status: status, departmentName: departmentName, facultyName: facultyName, programName: programName, latestGPA: latestGPA)
        }
        return nil
    }
    
    static func set(user: User) {
        UserDefaults.standard.set(user.username, forKey: keyUsername)
        UserDefaults.standard.set(user.name, forKey: keyname)
        UserDefaults.standard.set(user.status, forKey: keystatus)
        UserDefaults.standard.set(user.departmentName, forKey: keydepartmentName)
        UserDefaults.standard.set(user.facultyName, forKey: keyfacultyName)
        UserDefaults.standard.set(user.programName, forKey: keyprogramName)
        UserDefaults.standard.set(user.latestGPA, forKey: keylatestGPA)
    }
    
    static func isLoggedIn() -> Bool {
        return token() != nil
    }
    
    static func clear() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: keyAccessToken)
        ud.removeObject(forKey: keyUsername)
        ud.removeObject(forKey: keystatus)
        ud.removeObject(forKey: keydepartmentName)
        ud.removeObject(forKey: keyfacultyName)
        ud.removeObject(forKey: keyprogramName)
        ud.removeObject(forKey: keylatestGPA)
    }
}
