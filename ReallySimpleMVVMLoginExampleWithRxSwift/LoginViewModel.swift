//
//  LoginViewModel.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import RxSwift
import RxCocoa


struct LoginViewModel {
    
    let activityIndicator = ActivityIndicator()
    
    let usernameBGColor: Driver<UIColor>
    let passwordBGColor: Driver<UIColor>
    let credentialsValid: Driver<Bool>
    
    init(usernameText: Driver<String>, passwordText: Driver<String>) {
        
        let usernameValid = usernameText
            .distinctUntilChanged()
            .throttle(0.3)
            .map { $0.utf8.count > 3 }
        
        let passwordValid = passwordText
            .distinctUntilChanged()
            .throttle(0.3)
            .map { $0.utf8.count > 3 }
        
        usernameBGColor = usernameValid
            .map { $0 ? BG_COLOR : UIColor.whiteColor() }
        
        passwordBGColor = passwordValid
            .map { $0 ? BG_COLOR : UIColor.whiteColor() }
        
        credentialsValid = Driver.combineLatest(usernameValid, passwordValid) { $0 && $1 }
        
    }
    
    func login(username: String, password: String) -> Observable<AutenticationStatus> {
        return AuthManager.sharedManager.login(username, password: password)
    }
    
}


