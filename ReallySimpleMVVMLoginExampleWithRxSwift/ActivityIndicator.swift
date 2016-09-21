//
//  ActivityIndicator.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 10/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

private struct ActivityToken<E> : ObservableConvertibleType, Disposable {
    fileprivate let _source: Observable<E>
    fileprivate let _dispose: Cancelable

    init(source: Observable<E>, disposeAction: @escaping () -> ()) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    func dispose() {
        _dispose.dispose()
    }

    func asObservable() -> Observable<E> {
        return _source
    }
}

/**
Enables monitoring of sequence computation.

If there is at least one sequence computation in progress, `true` will be sent.
When all activities complete `false` will be sent.
*/
open class ActivityIndicator : DriverConvertibleType {
    public typealias E = Bool

    fileprivate let _lock = NSRecursiveLock()
    fileprivate let _variable = Variable(0)
    fileprivate let _loading: Driver<Bool>

    public init() {
        _loading = _variable.asObservable()
            .map { $0 > 0 }
            .distinctUntilChanged()
            .asDriver(onErrorRecover: ActivityIndicator.ifItStillErrors)
    }

    fileprivate static func ifItStillErrors(_ error: Error) -> Driver<Bool> {
        _ = fatalError("Loader can't fail")
    }


    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.E> {
        return Observable.using({ () -> ActivityToken<O.E> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in
            return t.asObservable()
        }
    }

    fileprivate func increment() {
        _lock.lock()
        _variable.value = _variable.value + 1
        _lock.unlock()
    }

    fileprivate func decrement() {
        _lock.lock()
        _variable.value = _variable.value - 1
        _lock.unlock()
    }

    open func asDriver() -> Driver<E> {
        return _loading
    }
}

public extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<E> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}
