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
    
    func loginAnonymously() {
        print("login Anonymously did tapped")
        //Annonymously log users in
        //Switch view by setting navigation controller as root view controller
        
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if error == nil {
                print("User ID: \(user!.uid)")
                self.switchToChatViewController()
            } else {
                print(error!.localizedDescription)
                return
            }
        })
        
        
    }
    
    func switchToChatViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "chatVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = chatVC
        
    }
    
    func switchToTabbarViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarVC = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarVC
    
    }
    

}
