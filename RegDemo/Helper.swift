//
//  Helper.swift
//  RegDemo
//
//  Created by B13 on 7/27/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit

class Helper : UIViewController {
    static let helper = Helper()
    
    func loginAnonymously(completion: @escaping (Bool) -> ()) {
        //Annonymously log users in
        //Switch view by setting navigation controller as root view controller
        
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if error == nil {
                print("User ID: \(user!.uid)")
                self.switchToTabbarViewController()
                completion(true)
            } else {
                print(error!.localizedDescription)
                completion(false)
            }
        })
    }
    
    func switchToTabbarViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarVC = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarVC
    }
    
    func switchToLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
    }
}
