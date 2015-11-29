//
//  LoginNavigationController.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import UIKit

class LoginNavigationController: UINavigationController {
    
    var loginController: LoginViewController? {
        return _loginController()
    }
    
    private func _loginController() -> LoginViewController? {
        return viewControllers.first as? LoginViewController
    }

}
