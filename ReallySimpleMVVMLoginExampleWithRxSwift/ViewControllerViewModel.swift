//
//  ViewControllerViewModel.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import RxSwift
import RxCocoa


class ViewControllerViewModel {
    
    let loginStatus = AuthManager.sharedManager.status.asDriver(onErrorJustReturn: .None)
    
    func logout() {
        AuthManager.sharedManager.logout()
    }
    
}