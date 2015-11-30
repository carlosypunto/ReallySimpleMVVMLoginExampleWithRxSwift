//
//  AuthManager.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import RxSwift

typealias JSONDictionary = [String:AnyObject]

enum AutenticationStatus {
    case Error(String)
    case None
    case User(String)
}

class AuthManager {
    
    let status = Variable(AutenticationStatus.None)
    
    static var sharedManager = AuthManager()
    
    private init() {}
    
    func login(username: String, password: String) -> Observable<AutenticationStatus> {
        let url = NSURL(string: "http://localhost:3000/login/\(username)/\(password)")!
        return NSURLSession.sharedSession().rx_JSON(url)
            .map {
                guard let root = $0 as? JSONDictionary,
                    let loginStatus = root["login_status"] as? Bool else {
                    return .Error("Invalid server response")
                }
                
                if loginStatus {
                    guard let user = root["user"] as? JSONDictionary,
                    let firstname = user["firstname"] as? String,
                    let lastname = user["lastname"] else {
                        return .Error("Invalid server response")
                    }
                    return .User("\(firstname) \(lastname)")
                }
                else {
                    return .None
                }
            }
            .catchErrorJustReturn(.Error("Server error"))
    }
    
    func logout() {
        status.value = .None
    }
    
}
