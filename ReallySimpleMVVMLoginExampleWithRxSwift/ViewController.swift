//
//  ViewController.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    let viewModel = ViewControllerViewModel()
    
    var loginNavigationController: LoginNavigationController?
    var loginController: LoginViewController?
    
    @IBOutlet weak var infoLabel: UILabel!
    
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.loginStatus
            .driveNext { [weak self] status in
                switch status {
                case .None:
                    self?.showLogin()
                case .User(let user):
                    self?.showAccess(user)
                }
            }
            .addDisposableTo(disposeBag)
        
        logoutButton.rx_tap
            .subscribeNext { _ in
                AuthManager.sharedManager.status.value = .None
            }
            .addDisposableTo(disposeBag)
    }
    
    func showLogin() {
        if loginNavigationController == nil {
            loginNavigationController = UIStoryboard.loginNC
            loginController = loginNavigationController?.loginController
            presentViewController(loginNavigationController!, animated: true, completion: nil)
        }
        infoLabel.text = ""
    }
    
    func showAccess(username: String) {
        infoLabel.text = "You are logged in with username: \(username)"
        dismissViewControllerAnimated(true) { [weak self] in
            self?.loginController = nil
            self?.loginNavigationController = nil
        }
    }
    
}


private extension UIStoryboard {
    
    weak static var mainStoryboard: UIStoryboard? {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    weak static var loginNC: LoginNavigationController? {
        return UIStoryboard.mainStoryboard?.instantiateViewControllerWithIdentifier("LoginNC") as? LoginNavigationController
    }
    
}