//
/*
* ****************************************************************
*
* 文件名称 : Combine+XT
* 作   者 : Created by 坤
* 创建时间 : 2022/4/14 15:05
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/14 初始版本
*
* ****************************************************************
*/

import Foundation
import Combine

extension Subject {

    public func asAnySubscriber() -> AnySubscriber<Self.Output, Self.Failure> {
        .init(self)
    }

    /*
    public func asAnySubscriber() -> AnySubscriber<Self.Output, Self.Failure> {

        let skinSubscriber = Subscribers.Sink<Output, Failure>.init { [weak self] com in
            self?.send(completion: com)
        } receiveValue: { [weak self]  value in
            self?.send(value)
        }

        return AnySubscriber(skinSubscriber)
    }
     */
}

extension Publisher {

    public func onMainScheduler() -> AnyPublisher<Self.Output, Self.Failure> {
        receive(on: RunLoop.main).eraseToAnyPublisher()
    }

    public func mapToVoid() -> Publishers.Map<Self, Void> {
        map { _ in }
    }
}
