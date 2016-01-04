//
//  LoginViewController.swift
//  ReallySimpleMVVMLoginExampleWithRxSwift
//
//  Created by Carlos García on 28/11/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class LoginViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        let gr = UITapGestureRecognizer()
        gr.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(gr)
        gr.rx_event.asObservable()
            .subscribeNext { [unowned self] _ in
                self.hideKeyboard()
            }
            .addDisposableTo(disposeBag)
        
        let viewModel = LoginViewModel(usernameText: usernameTextField.rx_text.asDriver(),
            passwordText: passwordTextField.rx_text.asDriver())
        
        viewModel.usernameBGColor
            .driveNext { [unowned self] color in
                UIView.animateWithDuration(0.2) {
                    self.usernameTextField.superview?.backgroundColor = color
                }
            }
            .addDisposableTo(disposeBag)
        
        
        viewModel.passwordBGColor
            .driveNext { [unowned self] color in
                UIView.animateWithDuration(0.2) {
                    self.passwordTextField.superview?.backgroundColor = color
                }
            }
            .addDisposableTo(disposeBag)
        
        viewModel.credentialsValid
            .driveNext { [unowned self] valid in
                self.enterButton.enabled = valid
            }
            .addDisposableTo(disposeBag)
        
        enterButton.rx_tap
            .withLatestFrom(viewModel.credentialsValid)
            .filter { $0 }
            .flatMapLatest { [unowned self] valid -> Observable<AutenticationStatus> in
                viewModel.login(self.usernameTextField.text!, password: self.passwordTextField.text!)
                    .trackActivity(viewModel.activityIndicator)
                    .observeOn(SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
            }
            .observeOn(MainScheduler.instance)
            .subscribeNext { [unowned self] autenticationStatus in
                switch autenticationStatus {
                case .User(_):
                    break
                case .Error(let error):
                    self.showError(error)
                case .None:
                    let alertController = UIAlertController(title: "Bad credentials", message: "Try it with the words 'user' and 'password'", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                AuthManager.sharedManager.status.value = autenticationStatus
            }
            .addDisposableTo(disposeBag)
        
        
        viewModel.activityIndicator
            .distinctUntilChanged()
            .driveNext { [unowned self] active in
                self.hideKeyboard()
                self.activityIndicator.hidden = !active
                self.enterButton.enabled = !active
            }
            .addDisposableTo(disposeBag)
        
    }
    
    private func hideKeyboard() {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    private func showError(error: String) {
        let alert = UIAlertController(title: "An error occuried", message: error, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
