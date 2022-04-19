//
/*
* ****************************************************************
*
* 文件名称 : UIControl+Combine
* 作   者 : Created by 坤
* 创建时间 : 2022/4/15 10:05
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/15 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import Combine


extension UIButton {

    public func subscriber(forTitle state: UIControl.State) -> AnySubscriber<String, Never> {
        .init(Subscribers.Sink<String, Never> { _ in
            print("Subscriber<Button.title> finished! ____&")
        } receiveValue: { [weak self] value in
            self?.setTitle(value, for: state)
        })
    }
}


fileprivate extension UIControl {

    func publisher1(forAction event: UIControl.Event) -> AnyPublisher<UIControl, Never> {
        #if true
        let publisher = ControlPublisher1(control: self, event: event)
            .eraseToAnyPublisher()
        return publisher

        #else

        let eventKey = event.publisherActionKey
        if let publisher = objc_getAssociatedObject(self, eventKey) as? AnyPublisher<UIControl, Never> {
            return publisher
        } else {
            let publisher = ControlPublisher1(control: self, event: event)
                .eraseToAnyPublisher()
            objc_setAssociatedObject(self, eventKey, publisher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return publisher
        }
        #endif
    }
}

fileprivate final class ControlPublisher1<Control: UIControl>: Publisher {

    typealias Failure = Never
    typealias Output = Control

    private weak var control: Control?
    private let event: UIControl.Event

    private var cancelStore: [(() -> Void)] = []

    init(control: Control, event: UIControl.Event) {
        self.control = control
        self.event = event
    }

    deinit {
        // NOTE: - 1. 虽然能够实现内存释放, 但 share() 操作后 ControlPublisher1 会强引用
        // NOTE: - 2. 此种情况下 deinit 不会执行, 形成循环引用
        // cancelStore.forEach { $0() }
        Swift.print("ControlPublisher1<\(type(of: control))> deinit! ____#")
    }

    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Control == S.Input {
        let subscription = ControlSubscription(subscriber: subscriber, control: control, event: event)
        // cancelStore.append(subscription.cancel)
        subscriber.receive(subscription: subscription)
    }
}

fileprivate final class ControlSubscription<S: Subscriber, Control: UIControl>: Combine.Subscription where S.Input == Control, S.Failure == Never {

    private weak var control: Control?
    private var subscriber: S?

    init(subscriber: S, control: Control?, event: UIControl.Event) {
        print("ControlSubscription<\(type(of: control))> init! ____^")
        self.control = control
        self.subscriber = subscriber
        control?.addTarget(self, action: #selector(doAction(sender:)), for: event)
    }

    deinit {
        Swift.print("ControlSubscription<\(type(of: control))> deinit! ____#")
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else {
            cancel()
            return
        }
    }

    // NOTE: - 释放内存
    func cancel() {
        subscriber = nil
        print("ControlSubscription<\(type(of: control))> cancel! ____@")
    }

    @objc private func doAction(sender: UIControl) {
        if let control = control {
            _ = subscriber?.receive(control)
        }
    }
}


fileprivate extension UIControl {

    func publisher2(forAction event: UIControl.Event) -> AnyPublisher<UIControl, Never> {
        let eventKey = event.publisherActionKey
        if let publisher = objc_getAssociatedObject(self, eventKey) as? AnyPublisher<UIControl, Never> {
            return publisher
        } else {
            let publisher = ControlPublisher2(control: self, event: event)
                .eraseToAnyPublisher()
            objc_setAssociatedObject(self, eventKey, publisher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return publisher
        }
    }
}

fileprivate final class ControlPublisher2: Publisher {

    typealias Failure = Never
    typealias Output = UIControl

    private weak var control: UIControl?

    // 经典类型摸除, 更多请参考:
    // https://www.swiftbysundell.com/articles/type-erasure-using-closures-in-swift/
    // https://www.swiftbysundell.com/articles/different-flavors-of-type-erasure-in-swift/

    // 模仿多次订阅
    private var sendControls: [((UIControl) -> Void)] = []
    private var sendFinished: [(() -> Void)] = []

    init(control: UIControl, event: UIControl.Event) {
        self.control = control
        control.addTarget(self, action: #selector(doAction(sender:)), for: event)
    }

    deinit {
        sendFinished.forEach { $0() }

        sendControls.removeAll()
        sendFinished.removeAll()
        Swift.print("ControlPublisher2<\(type(of: control))> deinit! ____#")
    }

    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, UIControl == S.Input {
        sendControls.append({ ctr in _ = subscriber.receive(ctr) })
        sendFinished.append({ subscriber.receive(completion: .finished) })
        subscriber.receive(subscription: Subscriptions.empty)
    }

    @objc private func doAction(sender: UIControl) {
        if let control = control {
            sendControls.forEach { $0(control) }
        }
    }
}

/// 最终使用版本
extension UIControl {

    public func publisher(forAction event: UIControl.Event) -> AnyPublisher<UIControl, Never> {
        // NOTE: - 根据 event 生成关联对象的 key
        let eventKey = event.publisherActionKey
        if let wraped = objc_getAssociatedObject(self, eventKey) as? ControlPublisher3 {
            return wraped.publisher
        } else {
            let publisher = ControlPublisher3(control: self, event: event)
            // NOTE: - 这里需要强持有 publisher, 类似于 View 强持有 ViewModel
            objc_setAssociatedObject(self, eventKey, publisher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return publisher.publisher
        }
    }
}


fileprivate final class ControlPublisher3 {

    private let subject = PassthroughSubject<UIControl, Never>()
    let publisher: AnyPublisher<UIControl, Never>

    private weak var control: UIControl?

    init(control: UIControl, event: UIControl.Event) {
        self.control = control
        self.publisher = self.subject.eraseToAnyPublisher()

        control.addTarget(self, action: #selector(doAction(sender:)), for: event)
    }

    deinit {
        subject.send(completion: .finished)
        Swift.print("ControlPublisher3<\(type(of: control))> deinit! ____#")
    }

    @objc private func doAction(sender: UIControl) {
        if let control = control {
            subject.send(control)
        }
    }
}
