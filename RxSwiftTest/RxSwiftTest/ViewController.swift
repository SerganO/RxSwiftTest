//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        testingObservable()
//        testingSubject()
    }
    
    
    func testingSubject() {
        let subject = PublishSubject<Int>()

        subject.subscribe { (event) in
            print("first subscriber \(event)")
        }

        subject.onNext(1)

        _ = subject.subscribe({ (event) in
            print("second subscriber \(event)")
        })

        subject.onNext(2)
        subject.onNext(3)
        subject.onNext(4)
        
        let replaySubject = ReplaySubject<Int>.create(bufferSize: 3)

        replaySubject.subscribe { (event) in
            print("first replay subscriber \(event)")
        }

        replaySubject.onNext(1)

        _ = replaySubject.subscribe { (event) in
            print("second replay subscriber \(event)")
        }

        replaySubject.onNext(2)
        replaySubject.onNext(3)

        replaySubject.subscribe { (event) in
            print("third replay subscriber \(event)")
        }

        replaySubject.onNext(4)
        
        let behaviorSubject = BehaviorSubject<Int>(value: 0)
        
        behaviorSubject.subscribe { (event) in
            print("first behavior subscriber \(event)")
        }
        
        behaviorSubject.onNext(1)
        
        behaviorSubject.subscribe { (event) in
            print("second behavior subscriber \(event)")
        }
        
        behaviorSubject.onNext(2)
        behaviorSubject.onNext(3)
        
        behaviorSubject.subscribe { (event) in
            print("third behavior subscriber \(event)")
        }
        
        behaviorSubject.onNext(4)
    }
    
    
    func testingObservable() {
        let observable = Observable<String>.just("First observable")

        _ = observable.subscribe(onNext: { (event) in
            print(event)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("finish")
        }) {
            print("disposed")
        }


        let sequence = Observable<Int>.of(1, 2, 3, 4, 5, 6)

        _ = sequence.subscribe({ (event) in
            print(event)
        })

        let array = [1, 2, 3]

        let observableFromArray = Observable<Int>.from(array).filter { $0 >= 2}.map { $0 * 2 }
        _ = observableFromArray.subscribe({ (event) in
            print(event)
        }).disposed(by: bag)
        
        
        let Array = [1, 1, 1, 2, 3, 3, 4, 5, 6, 6, 5, 7]
        let observableForFilter = Observable<Int>.from(Array)

        let filteredObservable = observableForFilter.distinctUntilChanged()

        _ = filteredObservable.subscribe({ (e) in
            print(e)
        }).disposed(by: bag)

        _ = filteredObservable.takeLast(4).subscribe({ (e) in
            print(e)
        }).disposed(by: bag)

        let intervalObservable = Observable<Int>.interval(1.5, scheduler: MainScheduler.instance)

        let throttleObservable = intervalObservable.throttle(1.0, scheduler: MainScheduler.instance)

        _ = throttleObservable.subscribe({ (e) in
            print("throttle \(e)")
        }).disposed(by: bag)

        let debounceObservable = intervalObservable.debounce(1.0, scheduler: MainScheduler.instance)

        _ = debounceObservable.subscribe({ (e) in
            print("debounce \(e)")
        }).disposed(by: bag)
        
        
        let  threadObservable = Observable<Int>.create { (observer) -> Disposable in
            print("thread observable -> \(Thread.current)")
            observer.onNext(1)
            observer.onNext(2)
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        
        _ = threadObservable.observeOn(MainScheduler.instance).subscribe({ (e) in
            print("thread -> \(Thread.current)")
            print(e)
        })
        
        let rxRequest = URLSession.shared.rx.data(request: URLRequest(url: URL(string: "http://jsonplaceholder.typicode.com/posts/1")!)).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        
        _ = rxRequest
            .observeOn(MainScheduler.instance)
            .subscribe { (event) in
                print("данные \(event)")
                print("thread \(Thread.current)")
        }
    }
    
    
}

