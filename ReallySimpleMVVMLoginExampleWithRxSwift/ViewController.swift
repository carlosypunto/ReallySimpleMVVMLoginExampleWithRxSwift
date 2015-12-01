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
    
    let disposeBag = DisposeBag()
    let viewModel = ViewControllerViewModel()
    
    @IBOutlet weak var infoView: UIView!
    var loginNavigationController: LoginNavigationController?
    var loginController: LoginViewController?
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.loginStatus
            .driveNext { [unowned self] status in
                switch status {
                case .None:
                    self.showLogin()
                case .Error(_):
                    self.showLogin()  
                case .User(let user):
                    self.showAccess(user)
                }
            }
            .addDisposableTo(disposeBag)
        
        logoutButton.rx_tap
            .subscribeNext { [unowned self] _ in
                self.viewModel.logout()
            }
            .addDisposableTo(disposeBag)
    }
    
    private func showLogin() {
        infoView.hidden = true
        infoLabel.text = ""
        guard loginNavigationController != nil else {
            loginNavigationController = UIStoryboard.loginNC
            loginController = loginNavigationController?.loginController
            presentViewController(loginNavigationController!, animated: true, completion: nil)
            return
        }
    }
    
    private func showAccess(username: String) {
        infoView.hidden = false
        infoLabel.text = "You are logged in with username: \(username)"
        dismissViewControllerAnimated(true) { [unowned self] in
            self.loginController = nil
            self.loginNavigationController = nil
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