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
        let sinkSubscriber = Subscribers.Sink<String, Never> { _ in
        } receiveValue: { [weak self] value in
            self?.setTitle(value, for: state)
        }
        return .init(sinkSubscriber)
    }
}


extension UIControl {

    public func publisher(forAction event: UIControl.Event) -> AnyPublisher<UIControl, Never> {
        ControlPublisher.init(control: self, event: event).eraseToAnyPublisher()
    }
}

fileprivate final class ControlPublisher<Control: UIControl>: Publisher {

    typealias Failure = Never
    typealias Output = Control

    private let control: Control
    private let event: UIControl.Event

    init(control: Control, event: UIControl.Event) {
        self.control = control
        self.event = event
    }

    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Control == S.Input {
        let subscription = ControlSubscription(subscriber: subscriber, control: control, event: event)
        subscriber.receive(subscription: subscription)
    }
}

fileprivate final class ControlSubscription<S: Subscriber, Control: UIControl>: Combine.Subscription where S.Input == Control, S.Failure == Never {

    private var contol: Control?
    private var subscriber: S?

    init(subscriber: S, control: Control, event: UIControl.Event) {
        self.contol = control
        self.subscriber = subscriber
        control.addTarget(self, action: #selector(doAction(sender:)), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
    }

    func cancel() {
        subscriber = nil
        contol = nil
    }

    @objc private func doAction(sender: UIControl) {
        if let contol = contol {
            _ = subscriber?.receive(contol)
        }
    }
}
