//
/*
* ****************************************************************
*
* 文件名称 : XTCombineNetworkService
* 作   者 : Created by 坤
* 创建时间 : 2022/4/9 11:20
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/9 初始版本
*
* ****************************************************************
*/

import Foundation
import Combine
import Moya
import Cache

/// 实际发送网络请求的 provider
fileprivate let xtProvider = MoyaProvider<MultiTarget>()

/// memory 缓存的单例
fileprivate let kMemoryStroage: MemoryStorage<String, Any> = .init(config: MemoryConfig())


extension TargetType {

    public func request() -> AnyPublisher<Response, MoyaError> {
        xtProvider.requestPublisher(.target(self))
    }

    /// 使用时间缓存策略, 内存中有数据就不请求网络
    public func memoryCacheIn(_ seconds: TimeInterval = 180) -> TargetOnMemoryCache {
        TargetOnMemoryCache(target: self, cacheTime: seconds)
    }

    /// 读取磁盘缓存, 一般用于启动时先加载数据, 而后真正的读取网络数据
    public func onStorage<T: Codable>(_ type: T.Type, atKeyPath keyPath: String? = nil, onDisk: ((T) -> ())?) -> TargetOnDiskStorage<T> {
        let diskStore: TargetOnDiskStorage<T> = .init(target: self, keyPath: keyPath)
        if let storage = diskStore.readDiskStorage(type) { onDisk?(storage) }
        return diskStore
    }
}


public struct TargetOnMemoryCache {

    private let target: TargetType
    private let cacheTime: TimeInterval
    private let subject = CurrentValueSubject<Response?, MoyaError>(nil)

    fileprivate init(target: TargetType, cacheTime: TimeInterval) {
        self.target = target
        self.cacheTime = cacheTime
    }

    public func request() -> AnyPublisher<Response, MoyaError> {

        let cacheKey = target.cacheKey
        if let cache = cachedResponse(for: cacheKey) {
            subject.send(cache)
            return subject.compactMap { $0 }.eraseToAnyPublisher()
        }

        let seconds = cacheTime

        return target.request().map { response -> Response in
            kMemoryStroage.setObject(response, forKey: cacheKey, expiry: .seconds(seconds))
            return response
        }
        .eraseToAnyPublisher()
    }

    /// 内存中缓存的数据
    private func cachedResponse(for key: String) -> Response? {

        do {
            let cacheData = try kMemoryStroage.object(forKey: key)
            if let response = cacheData as? Response {
                return response
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
}

public struct TargetOnDiskStorage<T: Codable> {

    private let target: TargetType
    private let keyPath: String?

    fileprivate init(target: TargetType, keyPath: String? = nil) {
        self.target = target
        self.keyPath = keyPath
    }

    public func request() -> AnyPublisher<Response, MoyaError> {

        target.request().map { response -> Response in
            do {
                let model = try response.map(T.self)
                try self.writeToDiskStorage(model)
            } catch {
                print(error)
            }

            return response
        }
        .eraseToAnyPublisher()
    }

    /// 从磁盘读取
    fileprivate func readDiskStorage<T: Codable>(_ type: T.Type) -> T? {
        do {
            let key = target.cacheKey
            let config = DiskConfig(name: "\(type.self)")
            let transformer = TransformerFactory.forCodable(ofType: type.self)
            let storage = try DiskStorage<String, T>.init(config: config, transformer: transformer)
            let model = try storage.object(forKey: key)
            return model
        } catch {
            print(error)
            return nil
        }
    }

    fileprivate func writeToDiskStorage<T: Codable>(_ model: T) throws {
        let config = DiskConfig(name: "\(T.self)")
        let transformer = TransformerFactory.forCodable(ofType: T.self)
        let storage = try DiskStorage<String, T>.init(config: config, transformer: transformer)
        try storage.setObject(model, forKey: target.cacheKey)
    }
}

/*
private func cachedResponse(for key: String) -> Response? {

    do {
        let cacheData = try kMemoryStroage.object(forKey: key)
        if let response = cacheData as? Response {
            return response
        } else {
            return nil
        }
    } catch {
        return nil
    }
}

// 类似上篇中的封装方式
extension AnyPublisher {

    func request() -> AnyPublisher<Response, MoyaError> where Output == (TargetType, TimeInterval), Failure == MoyaError {
        flatMap { tuple -> AnyPublisher<Response, MoyaError> in
            let target = tuple.0
            let cacheKey = target.cacheKey
            if let response = cachedResponse(for: cacheKey) {
                return CurrentValueSubject(response).eraseToAnyPublisher()
            }

            return target.request().map { response -> Response in
                 kMemoryStroage.setObject(response, forKey: cacheKey, expiry: .seconds(seconds))
                 return response
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
 
extension CurrentValueSubject {

    func request() -> AnyPublisher<Response, MoyaError> where Output == CacheTimeTargetTuple, Failure == MoyaError {

        flatMap { tuple -> AnyPublisher<Response, MoyaError> in
           let target = tuple.target
           if let response = target.cachedResponse() {
               return CurrentValueSubject<Response, MoyaError>(response).eraseToAnyPublisher()
           }

           let cacheKey = target.cacheKey
           let seconds = tuple.cacheTime

           return target.request().map { response -> Response in
               kMemoryStroage.setObject(response, forKey: cacheKey, expiry: .seconds(seconds))
               return response
           }
           .eraseToAnyPublisher()
       }
       .eraseToAnyPublisher()
    }
}
*/
