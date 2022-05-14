//
/*
* ****************************************************************
*
* 文件名称 : JsonDataPublisher
* 作   者 : Created by 坤
* 创建时间 : 2022/4/14 16:51
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/14 初始版本
*
* ****************************************************************
*/

import Foundation
import Combine

 
enum BundleJsonDataError: Error {
    case noFile
    case noData
    case noValidateData
    case modelMapping
}


final class BundleJsonDataPublisher<Output: Decodable>: Publisher {

    typealias Failure = BundleJsonDataError

    private let filePath: String?

    init(filePaht: String?) {
        self.filePath = filePaht
    }

    // deinit { Swift.print("\(type(of: self)) deinit! ____#") }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = BundleJsonDataSubscription(filePath: filePath, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}


fileprivate final class BundleJsonDataSubscription<S: Subscriber>: Combine.Subscription where S.Input: Decodable, S.Failure == BundleJsonDataError {

    private let filePath: String?
    private var subscriber: S?
    private var task: DispatchWorkItem?

    init(filePath: String?, subscriber: S?) {
        self.filePath = filePath
        self.subscriber = subscriber
    }

    // deinit { print("\(type(of: self)) deinit! ____#") }

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else { return }
        guard let subscriber = subscriber else { return }

        guard let filePath = filePath, FileManager.default.fileExists(atPath: filePath) else {
            subscriber.receive(completion: .failure(.noFile))
            return
        }

        let topicFileUrl = URL(fileURLWithPath: filePath)

        task = DispatchWorkItem {
            
            guard let jsonData = try? Data(contentsOf: topicFileUrl) else {
                subscriber.receive(completion: .failure(.noData))
                return
            }

            do {
                let wrappedModel = try JSONDecoder().decode(S.Input.self, from: jsonData)
                _ = subscriber.receive(wrappedModel)
                subscriber.receive(completion: .finished)
            } catch let error {
                debugPrint(error)
                // TODO: - 根据 error 区分 noValidateData 和 modelMapping
                subscriber.receive(completion: .failure(.modelMapping))
            }
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval(0.5), execute: task!)
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}

fileprivate extension Publishers {

    /// 十分简单的一次模仿, 无实际使用价值
    struct IsMainThreed: Publisher {
        typealias Output = Bool
        typealias Failure = Never

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            subscriber.receive(subscription: Subscriptions.empty)
            let inMain = Thread.isMainThread
            DispatchQueue.main.async {
                _ = subscriber.receive(inMain)
            }
        }
    }
}
