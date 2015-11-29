//
//  AuthManager.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import RxSwift

enum AutenticationStatus {
    case None
    case User(String)
}

class AuthManager {
    
    let status = Variable(AutenticationStatus.None)
    
    static var sharedManager = AuthManager()
    
    private init() {}
    
    func login(username: String, password: String) -> Observable<AutenticationStatus> {
        return create { observer -> Disposable in
            
            // Simulate delay of network connection
            dispatch_after(4, dispatch_get_main_queue()) {
                if (username == "user" && password == "password") {
                    observer.onNext(.User(username))
                }
                else {
                    observer.onNext(.None)
                }
                observer.onCompleted()
            }
            return AnonymousDisposable({})
        }
        .delaySubscription(4, MainScheduler.sharedInstance)
    }
    
}
