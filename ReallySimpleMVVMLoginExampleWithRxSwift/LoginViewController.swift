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
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        let gr = UITapGestureRecognizer()
        gr.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(gr)
        gr.rx.event.asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.hideKeyboard()
            })
            .addDisposableTo(disposeBag)
        
        let viewModel = LoginViewModel(usernameText: usernameTextField.rx.text.orEmpty.asDriver(),
            passwordText: passwordTextField.rx.text.orEmpty.asDriver())
        
        viewModel.usernameBGColor
            .drive(onNext: { [unowned self] color in
                UIView.animate(withDuration: 0.2) {
                    self.usernameTextField.superview?.backgroundColor = color
                }
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.passwordBGColor
            .drive(onNext: { [unowned self] color in
                UIView.animate(withDuration: 0.2) {
                    self.passwordTextField.superview?.backgroundColor = color
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.credentialsValid
            .drive(onNext: { [unowned self] valid in
                self.enterButton.isEnabled = valid
            })
            .addDisposableTo(disposeBag)
        
        enterButton.rx.tap
            .withLatestFrom(viewModel.credentialsValid)
            .filter { $0 }
            .flatMapLatest { [unowned self] valid -> Observable<AutenticationStatus> in
                viewModel.login(self.usernameTextField.text!, password: self.passwordTextField.text!)
                    .trackActivity(viewModel.activityIndicator)
                    .observeOn(SerialDispatchQueueScheduler(qos: .userInteractive))
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] autenticationStatus in
                switch autenticationStatus {
                case .none:
                    break
                case .user(_):
                    break
                case .error(let error):
                    self.showError(error)
                }
                AuthManager.sharedManager.status.value = autenticationStatus
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.activityIndicator
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] active in
                self.hideKeyboard()
                self.activityIndicator.isHidden = !active
                self.enterButton.isEnabled = !active
            })
            .addDisposableTo(disposeBag)
        
    }
    
    fileprivate func hideKeyboard() {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    fileprivate func showError(_ error: AutenticationError) {
        let title: String
        let message: String
        
        switch error {
        case .server, .badReponse:
            title = "An error occuried"
            message = "Server error"
        case .badCredentials:
            title = "Bad credentials"
            message = "This user don't exist"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}
