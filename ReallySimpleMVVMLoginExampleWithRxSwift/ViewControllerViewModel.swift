//
//  ViewControllerViewModel.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import RxSwift
import RxCocoa


struct ViewControllerViewModel {
    
    let loginStatus = AuthManager.sharedManager.status.asDriver().asDriver(onErrorJustReturn: .None)
    
    func logout() {
        AuthManager.sharedManager.logout()
    }
    
}