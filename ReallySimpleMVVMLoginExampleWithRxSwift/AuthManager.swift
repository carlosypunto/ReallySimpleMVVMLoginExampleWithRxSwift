//
//  AuthManager.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import RxSwift

typealias JSONDictionary = [String: Any]

enum AutenticationError: Error {
    case server
    case badReponse
    case badCredentials
}

enum AutenticationStatus {
    case none
    case error(AutenticationError)
    case user(String)
}

class AuthManager {
    
    let status = Variable(AutenticationStatus.none)
    
    static var sharedManager = AuthManager()
    
    fileprivate init() {}
    
    func login(_ username: String, password: String) -> Observable<AutenticationStatus> {
        let url = URL(string: "http://localhost:3000/login/\(username)/\(password)")!
        return URLSession.shared.rx.json(url: url)
            .map {
                guard let root = $0 as? JSONDictionary,
                    let loginStatus = root["login_status"] as? Bool else {
                    return .error(.badReponse)
                }
                
                if loginStatus {
                    guard let user = root["user"] as? JSONDictionary,
                    let firstname = user["firstname"] as? String,
                    let lastname = user["lastname"] else {
                        return .error(.badReponse)
                    }
                    return .user("\(firstname) \(lastname)")
                }
                else {
                    return .error(.badCredentials)
                }
            }
            .catchErrorJustReturn(.error(.server))
    }
    
    func logout() {
        status.value = .none
    }
    
}
