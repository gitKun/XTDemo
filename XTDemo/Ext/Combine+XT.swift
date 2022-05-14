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

extension Combine.Subject {

    public func asAnySubscriber() -> AnySubscriber<Self.Output, Self.Failure> {
        .init(self)
    }
}

extension Combine.Publisher {

    public func onMainScheduler() -> AnyPublisher<Self.Output, Self.Failure> {
        receive(on: RunLoop.main).eraseToAnyPublisher()
    }

    public func mapToVoid() -> Publishers.Map<Self, Void> {
        map { _ in }
    }
}

// FIXED: - receive(completion: .finished) 并不等效于 cancel
// - cancel 中才是释放内存的地方, completion: 仅仅标记结束订阅不再处理事件
// - 所以不应当对 `AnySubscriber` 追加的 `Cancellable`
// - 使用 `receive(completion:)` 作为 `cancel()` 的实现
/*extension AnySubscriber: Combine.Cancellable where Failure == Never {

    public func cancel() {
        receive(completion: .finished)
    }
}*/
