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
    
    private var disposeBag = DisposeBag()
    
    
    init(usernameText: Driver<String>, passwordText: Driver<String>) {
        
        let usernameValid = usernameText
            .distinctUntilChanged()
            .throttle(0.3, MainScheduler.sharedInstance)
            .map { $0.utf8.count > 3 }
        
        let passwordValid = passwordText
            .distinctUntilChanged()
            .throttle(0.3, MainScheduler.sharedInstance)
            .map { $0.utf8.count > 3 }
        
        usernameBGColor = usernameValid
            .map { $0 ? BG_COLOR : UIColor.whiteColor() }
        
        passwordBGColor = passwordValid
            .map { $0 ? BG_COLOR : UIColor.whiteColor() }
        
        credentialsValid = combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .asDriver(onErrorJustReturn: false)
        
    }
    
    func login(username: String, password: String) -> Observable<AutenticationStatus> {
        return AuthManager.sharedManager.login(username, password: password)
    }
    
}


