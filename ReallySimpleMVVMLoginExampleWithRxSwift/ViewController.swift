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
  
  override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      viewModel.loginStatus
        .drive(onNext: {
          [unowned self] status in
          switch status {
          case .none:
            self.showLogin()
          case .error(_):
            self.showLogin()
          case .user(let user):
            self.showAccess(user)
          }
        })
        .addDisposableTo(disposeBag)
    
      logoutButton.rx.tap
        .subscribe({
          [unowned self] _ in
          self.viewModel.logout()
        })
        .addDisposableTo(disposeBag)
  }
  
  fileprivate func showLogin() {
      infoView.isHidden = true
      infoLabel.text = ""
      guard loginNavigationController != nil else {
        loginNavigationController = UIStoryboard.loginNC
        loginController = loginNavigationController?.loginController
        present(loginNavigationController!, animated: true, completion: nil)
        return
      }
  }
  
  fileprivate func showAccess(_ username: String) {
      infoView.isHidden = false
      infoLabel.text = "You are logged in with username: \(username)"
      dismiss(animated: true) { [unowned self] in
        self.loginController = nil
        self.loginNavigationController = nil
      }
  }
    
}


private extension UIStoryboard {
    
  weak static var mainStoryboard: UIStoryboard? {
    return UIStoryboard(name: "Main", bundle: Bundle.main)
  }
  
  weak static var loginNC: LoginNavigationController? {
    return UIStoryboard.mainStoryboard?.instantiateViewController(withIdentifier: "LoginNC") as? LoginNavigationController
  }
    
}
