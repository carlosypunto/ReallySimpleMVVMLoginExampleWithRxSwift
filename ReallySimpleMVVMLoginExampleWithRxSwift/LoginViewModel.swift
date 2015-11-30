//
//  LoginViewModel.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class LoginViewModel {
    
    let activityIndicator = ActivityIndicator()
    
    let usernameValid: Driver<Bool>
    let passwordValid: Driver<Bool>
    let credentialsValid: Driver<Bool>
    
    private var disposeBag = DisposeBag()
    
    
    init(usernameObservable: Driver<String>,
        passwordObservable: Driver<String>) {
        
        usernameValid = usernameObservable
            .map {
                $0.utf8.count > 3
            }
        
        passwordValid = passwordObservable
            .map {
                $0.utf8.count > 3
            }
        
        credentialsValid = combineLatest(usernameValid, passwordValid) { $0 && $1
            }.asDriver(onErrorJustReturn: false)
        
    }
    
    func login(username: String, password: String) -> Observable<AutenticationStatus> {
        return AuthManager.sharedManager.login(username, password: password)
    }
    
}


