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
    // @NOTE: - 更应该使用 func 方式, 提醒调用者重复获取的并不是同一个订阅者
    func subscriber() -> Subscribers.Sink<Void, Never> {
        .init { _ in
            // FIXED: - self 必定为 nil
            print("MJRefreshHeader subscriber finished! ____&")
        } receiveValue: { [weak self] _ in
            self?.endRefreshing()
        }
    }
}

extension MJRefreshFooter {

    func subscriber() -> Subscribers.Sink<Bool, Never> {
        .init { _ in
            // FIXED: - self 必定已经释放
            print("MJRefreshFooter subscriber finished! ____&")
        } receiveValue: { [weak self] hasMore in
            (hasMore ? { self?.endRefreshing() } : { self?.endRefreshingWithNoMoreData() })()
        }
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

    private weak var control: Control?

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

    private var subscriber: S?
    private weak var control: Control?

    init(subscriber: S, control: Control?) {
        self.subscriber = subscriber
        self.control = control
        //control.setRefreshingTarget(self, refreshingAction: #selector(refreshing))
        // FIXDE: - 注意循环引用: control -> refreshingBlock -> control
        if let ctr = control {
            ctr.refreshingBlock = { [weak ctr] in
                if let ctr = ctr {
                    _ = subscriber.receive(ctr)
                }
            }
        }
    }

    deinit {
        print("MJRefreshingSubscription<\(type(of: control))> deinit! ____#")
    }

    func request(_ demand: Subscribers.Demand) {

        guard demand > 0 else {
            subscriber?.receive(completion: .finished)
            return
        }
        // 不作任何处理, 已经在 refreshing() 中通知 subscriber 接收 control
    }

    func cancel() {
        //print("MJRefreshingSubscription<\(type(of: control))> cancel! ____&")
        subscriber = nil
    }
}

