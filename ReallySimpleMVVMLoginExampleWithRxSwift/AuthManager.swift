//
//  AuthManager.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import RxSwift

typealias JSONDictionary = [String:AnyObject]

enum AutenticationError: ErrorType {
    case Server
    case BadReponse
    case BadCredentials
}

enum AutenticationStatus {
    case None
    case Error(AutenticationError)
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
                    return .Error(.BadReponse)
                }
                
                if loginStatus {
                    guard let user = root["user"] as? JSONDictionary,
                    let firstname = user["firstname"] as? String,
                    let lastname = user["lastname"] else {
                        return .Error(.BadReponse)
                    }
                    return .User("\(firstname) \(lastname)")
                }
                else {
                    return .Error(.BadCredentials)
                }
            }
            .catchErrorJustReturn(.Error(.Server))
    }
    
    func logout() {
        status.value = .None
    }
    
}
