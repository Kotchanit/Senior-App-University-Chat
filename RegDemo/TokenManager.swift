//
//  TokenManager.swift
//  RegDemo
//
//  Created by B13 on 7/19/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import Foundation

class TokenManager {
    static func get() -> Token? {
        if let tokenString = UserDefaults.standard.string(forKey: "AccessToken") {
            return Token(value: tokenString)
        }
        return nil
    }
    
    static func set(token:Token) {
        UserDefaults.standard.set(token.value, forKey: "AccessToken")
    }
    
    static func isLoggedIn() -> Bool {
        return get() != nil
    }
}
