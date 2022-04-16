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
        let sinkSubscriber = Subscribers.Sink<Void, Never>.init { _ in
            // FIXED: - self 必定为 nil
            print("MJRefreshHeader subscriber finished! ____&")
        } receiveValue: { [weak self] _ in
            self?.endRefreshing()
        }
        return .init(sinkSubscriber)
    }
}

extension MJRefreshFooter {

    func subscriber() -> AnySubscriber<Bool, Never> {
        let sinkSubscriber = Subscribers.Sink<Bool, Never>.init { _ in
            // FIXED: - self 必定已经释放
            print("MJRefreshFooter subscriber finished! ____&")
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

    deinit {
        Swift.print("MJRefreshingPublisher<\(type(of: control))> deinit! ____#")
    }

    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Control == S.Input {
        let subscription = MJRefreshingSubscription(subscriber: subscriber, control: control)
        subscriber.receive(subscription: subscription)
    }
}

fileprivate final class MJRefreshingSubscription<S: Subscriber, Control: MJRefreshComponent>: Subscription where S.Input == Control {

    private var subscriber: S
    private let control: Control

    init(subscriber: S, control: Control) {
        self.subscriber = subscriber
        self.control = control
        //control.setRefreshingTarget(self, refreshingAction: #selector(refreshing))
        // FIXDE: - 注意循环引用: control -> refreshingBlock -> control
        control.refreshingBlock = { [weak control] in
            if let ctr = control {
                _ = subscriber.receive(ctr)
            }
        }
    }

    deinit {
        print("MJRefreshingSubscription<\(type(of: control))> deinit! ____#")
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else { return subscriber.receive(completion: .finished) }
        // 不作任何处理, 已经在 refreshing() 中通知 subscriber 接收 control
    }

    func cancel() {
        //print("MJRefreshingSubscription<\(type(of: control))> cancel! ____&")
        // FIXED: - 必须通知 sbuscriber 事件完成, 停止订阅. 否则内存泄漏.
        subscriber.receive(completion: .finished)
    }
}

