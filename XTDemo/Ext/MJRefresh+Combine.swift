//
/*
* ****************************************************************
*
* 文件名称 : MJRefresh+Combine
* 作   者 : Created by 坤
* 创建时间 : 2022/4/14 15:07
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/14 初始版本
*
* ****************************************************************
*/

import Foundation
import MJRefresh
import Combine

extension MJRefreshHeader {

    // @NOTE: - 可以是 方法, 也可以是 计算属性, 都不支持多次加入到 发布者 中
    func subscriber() -> AnySubscriber<Void, Never> {
        let sinkSubscriber = Subscribers.Sink<Void, Never>.init { [weak self] _ in
            self?.endRefreshing()
        } receiveValue: { [weak self] _ in
            self?.endRefreshing()
        }
        return .init(sinkSubscriber)
    }
}

extension MJRefreshFooter {

    func subscriber() -> AnySubscriber<Bool, Never> {
        let sinkSubscriber = Subscribers.Sink<Bool, Never>.init { [weak self] _ in
            self?.endRefreshingWithNoMoreData()
        } receiveValue: { [weak self] hasMore in
            (hasMore ? { self?.endRefreshing() } : { self?.endRefreshingWithNoMoreData() })()
        }
        return .init(sinkSubscriber)
    }
}

extension MJRefreshComponent {

    var publisherRefreshing: AnyPublisher<MJRefreshComponent, Never> {
        return MJRefreshingPublisher(control: self).eraseToAnyPublisher()
    }
}


fileprivate final class MJRefreshingPublisher<Control: MJRefreshComponent>: Publisher {
    typealias Output = Control
    typealias Failure = Never

    let control: Control

    init(control: Control) {
        self.control = control
    }

    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Control == S.Input {
        let subscription = MJRefreshingSubscription(subscriber: subscriber, control: control)
        subscriber.receive(subscription: subscription)
    }
}

fileprivate final class MJRefreshingSubscription<S: Subscriber, Control: MJRefreshComponent>: Subscription where S.Input == Control {
    private var subscriber: S?
    private var control: Control?

    init(subscriber: S, control: Control) {
        self.subscriber = subscriber
        self.control = control
        control.setRefreshingTarget(self, refreshingAction: #selector(refreshing))
    }

    deinit {
        print("\(type(of: self)) deinit! ____#")
    }

    func request(_ demand: Subscribers.Demand) {
        // 不作任何处理, 已经在 refreshing() 中通知 subscriber 接收 control
    }

    func cancel() {
        subscriber = nil
        control = nil
    }

    @objc private func refreshing() {
        _ = subscriber?.receive(control!)
    }
}

/*
// TODO: - 拓展 button 的 点击, 长按 等功能
extension UIButton {

    public func publiser(action forState: UIControl.State) -> AnyPublisher<UIButton, Never> {

    }
}
*/

