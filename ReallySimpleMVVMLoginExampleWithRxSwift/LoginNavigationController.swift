//
//  LoginNavigationController.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import UIKit

let BG_COLOR = UIColor(red: 1, green: 175/255, blue: 66/255, alpha: 1)

class LoginNavigationController: UINavigationController {
    
    var loginController: LoginViewController? {
        return _loginController()
    }
    
    private func _loginController() -> LoginViewController? {
        return viewControllers.first as? LoginViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationBar.barTintColor = BG_COLOR
    }

}
