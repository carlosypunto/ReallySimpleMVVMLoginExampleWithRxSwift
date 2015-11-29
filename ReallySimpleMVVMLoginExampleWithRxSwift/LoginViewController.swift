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
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        let gr = UITapGestureRecognizer()
        gr.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(gr)
        gr.rx_event.asObservable()
            .subscribeNext { [weak self] _ in
                self?.usernameTextField.resignFirstResponder()
                self?.passwordTextField.resignFirstResponder()
            }
            .addDisposableTo(disposeBag)
        
        let usernameOb = usernameTextField.rx_text
            .distinctUntilChanged()
            .throttle(0.3, MainScheduler.sharedInstance)
            .asDriver(onErrorJustReturn: "")
        
        let passwordOb = passwordTextField.rx_text
            .distinctUntilChanged()
            .throttle(0.3, MainScheduler.sharedInstance)
            .asDriver(onErrorJustReturn: "")
        
        
        let viewModel = LoginViewModel(usernameObservable: usernameOb, passwordObservable: passwordOb)
        
        viewModel.usernameValid
            .map {
                $0 ? UIColor.whiteColor() : UIColor.yellowColor()
            }
            .driveNext { [weak self] color in
                self?.usernameTextField.backgroundColor = color
            }
            .addDisposableTo(disposeBag)
        
        
        viewModel.passwordValid
            .map {
                $0 ? UIColor.whiteColor() : UIColor.yellowColor()
            }
            .driveNext { [weak self] color in
                self?.passwordTextField.backgroundColor = color
            }
            .addDisposableTo(disposeBag)
        
        let credentialsValid = combineLatest(viewModel.usernameValid, viewModel.passwordValid) { userValid, passValid -> Bool in
                return userValid && passValid
            }.asDriver(onErrorJustReturn: false)
        
        credentialsValid
            .driveNext { [weak self] valid in
                self?.enterButton.enabled = valid
            }
            .addDisposableTo(disposeBag)
        
        enterButton.rx_tap
            .withLatestFrom(credentialsValid)
            .filter { $0 }
            .flatMapLatest { [weak self] valid -> Observable<AutenticationStatus> in
                viewModel.login(self!.usernameTextField.text!, password: self!.passwordTextField.text!)
                    
                    .trackActivity(viewModel.activityIndicator)
                    .observeOn(SerialDispatchQueueScheduler(globalConcurrentQueuePriority: .Default))
            }
            .observeOn(MainScheduler.sharedInstance)
            .subscribeNext { [weak self] autenticationStatus in
                switch autenticationStatus {
                case .User(_):
                    break
                case .None:
                    let alertController = UIAlertController(title: "Bad credentials", message: "Try it with the words 'user' and 'password'", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self?.presentViewController(alertController, animated: true, completion: nil)
                }
                AuthManager.sharedManager.status.value = autenticationStatus
            }
            .addDisposableTo(disposeBag)
        
        
        viewModel.activityIndicator
            .distinctUntilChanged()
            .driveNext { [weak self] active in
                self?.activityIndicator.hidden = !active
            }
            .addDisposableTo(disposeBag)
        
    }
    
}
