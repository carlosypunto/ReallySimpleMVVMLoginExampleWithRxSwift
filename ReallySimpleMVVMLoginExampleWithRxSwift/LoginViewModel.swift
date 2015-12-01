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
    
    let usernameValid: Driver<Bool>
    let passwordValid: Driver<Bool>
    let credentialsValid: Driver<Bool>
    
    private var disposeBag = DisposeBag()
    
    
    init(usernameText: Driver<String>, passwordText: Driver<String>) {
        
        usernameValid = usernameText
            .distinctUntilChanged()
            .throttle(0.3, MainScheduler.sharedInstance)
            .map {
                $0.utf8.count > 3
            }
        
        passwordValid = passwordText
            .distinctUntilChanged()
            .throttle(0.3, MainScheduler.sharedInstance)
            .map {
                $0.utf8.count > 3
            }
        
        credentialsValid = combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .asDriver(onErrorJustReturn: false)
        
    }
    
    func login(username: String, password: String) -> Observable<AutenticationStatus> {
        return AuthManager.sharedManager.login(username, password: password)
    }
    
}


