//
//  API.swift
//  RegDemo
//
//  Created by Ant on 21/03/2017.
//  Copyright © 2017 Apptitude. All rights reserved.
//

import Foundation
import Alamofire

//enum Result<T> {
//    case success(T)
//    case error(Error)
//}

enum DataError : Error {
    case parseError
    case unknown
}


class API {
    
    static let baseURL = "http://nuws.mobcomlab.com/"
    static let clientID = "1"
    static let clientSecret = "fVXeDDZwCUfQ7jxohQ1uwUZ6myzsvNynWaL4eGHd"
    
    static func login(username: String, password: String, completion: @escaping (Result<Token>) -> ()) {
        
        //print("user = \(username) pass = \(password)")
        
        let parameters: Parameters = ["grant_type": "password", "client_id": clientID, "client_secret": clientSecret, "username": username, "password": password]
        
        Alamofire.request(baseURL+"oauth/token", method: .post, parameters: parameters).responseJSON { response in
            
            if response.result.isSuccess, let json = response.result.value as? [String: Any], let tokenString = json["access_token"] as? String {
                completion(.success(Token(value: tokenString)))
            }
            else if case let .failure(error) = response.result {
                completion(.failure(error))
            }
            else {
                completion(.failure(DataError.unknown))
            }
        }
    }
    
    static func profile(token: Token, completion: @escaping (Result<User>) -> ()) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token.value)",
            "Accept": "application/json"
        ]
        
        Alamofire.request(baseURL+"api/profile", headers: headers).responseJSON { response in
            
            if response.result.isSuccess, let json = response.result.value as? [String: Any] {
                let username = json["username"] as? String ?? ""
                let name = json["name"] as? String ?? ""
                let status = json["status"] as? String ?? ""
                let departmentName = (json["department"] as? [String: Any] ?? [:])["name"] as? String ?? ""
                let facultyName = (json["faculty"] as? [String: Any] ?? [:])["name"] as? String ?? ""
                let programName = (json["program"] as? [String: Any] ?? [:])["name"] as? String ?? ""
                var latestGPAScore: Float?
                if let allGPA = json["gpax"] as? [Any], allGPA.count > 0,
                    let latestGPA = allGPA[0] as? [String:Any] {
                    latestGPAScore = (latestGPA["score"] as? NSString)?.floatValue
                }
                
                let user = User(username: username, name: name, status: status, departmentName: departmentName, facultyName: facultyName, programName: programName, latestGPA: latestGPAScore)
                completion(.success(user))
            }
            else if case let .failure(error) = response.result {
                completion(.failure(error))
            }
            else {
                completion(.failure(DataError.unknown))
            }
        }
    }
    
    static func profileImageURLRequest(token: Token) -> URLRequest? {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token.value)"
        ]
        
        return try! URLRequest(url: baseURL+"api/user/image", method: .get, headers: headers)
        
        //return user.status == "student" ? URL(string: "http://www.reg2.nu.ac.th/registrar/getstudentimage.asp?id=\(user.username)") : nil
    }
    
    static func subjects(token: Token, completion: @escaping (Result<[Subject]>) -> ()) {
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token.value)", "Accept": "application/json"]
        
        Alamofire.request(baseURL+"/api/subjects", headers: headers).responseJSON { response in
            
            if response.result.isSuccess, let json = response.result.value as? [String: Any], let subjectsRaw = json["subjects"] as? [[String: Any]] {
                
                var subjects: [Subject] = []
                
                // Convert each subject raw into a subject
                for subjectRaw in subjectsRaw {
                    // Get the data inside the subjectRaw
                    let subjectID = subjectRaw["subject_id"] as? String ?? ""
                    let code = subjectRaw["code"] as? String ?? ""
                    let nameTH = subjectRaw["name_th"] as? String ?? ""
                    let nameEN = subjectRaw["name_en"] as? String ?? ""
                    let credit = subjectRaw["credit"] as? String ?? ""
                    // Create the subject object
                    let subject = Subject(subjectID: subjectID, code: code, nameTH: nameTH, nameEN: nameEN, credit: credit)
                    subjects.append(subject)
                }
                
                completion(.success(subjects))
            }
            else if case let .failure(error) = response.result {
                completion(.failure(error))
            }
            else {
                completion(.failure(DataError.unknown))
            }
        }
        
    }

    
}
