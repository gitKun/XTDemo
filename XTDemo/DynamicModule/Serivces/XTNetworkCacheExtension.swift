//
/*
* ****************************************************************
*
* 文件名称 : XTNetworkCacheExtension
* 作   者 : Created by 坤
* 创建时间 : 2022/3/26 11:10 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/26 初始版本
*
* ****************************************************************
*/

#if false
import Foundation
import RxSwift
import Moya
import Cache

/// 实际发送网络请求的 provider
fileprivate let xtProvider = MoyaProvider<MultiTarget>()

/// memory 缓存的单例
fileprivate let kMemoryStroage: MemoryStorage<String, Any> = .init(config: MemoryConfig())


/// 替换现有的 plugins
///
/// Node: - 会涉及到 provider 的重新创建, 待定方法, 暂无实现!
///
/// - Parameter plugins: plugin 数组
fileprivate func changePlugins(_ plugins: [Moya.PluginType]) {}


// MARK: - 在内存中缓存

public typealias CacheTimeTargetTuple = (cacheTime: TimeInterval, target: TargetType)

extension PrimitiveSequence where Trait == SingleTrait, Element == CacheTimeTargetTuple {

    public func request() -> Single<Response> {
        flatMap { tuple -> Single<Response> in
            let target = tuple.target

            if let response = target.cachedResponse() {
                return .just(response)
            }

            let cacheKey = target.cacheKey
            let seconds = tuple.cacheTime
            let result = target.request().cachedIn(seconds: seconds, cacheKey: cacheKey)
            return result
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {

    fileprivate func cachedIn(seconds: TimeInterval, cacheKey: String) -> Single<Response> {
        flatMap { response -> Single<Response> in
            kMemoryStroage.setObject(response, forKey: cacheKey, expiry: .seconds(seconds))
            return .just(response)
        }
    }
}

// MARK: - 在磁盘中的缓存

public struct OnDiskStorage<Target: TargetType, T: Codable> {
    fileprivate let target: Target
    private var keyPath: String = ""

    fileprivate init(target: Target, keyPath: String) {
        self.target = target
        self.keyPath = keyPath
    }

    /// 每个包裹的结构体都提供 request 方法
    public func request() -> Single<Response> {
        return target.request().flatMap { response -> Single<Response> in
            do {
                let model = try response.map(T.self)
                try target.writeToDiskStorage(model)
            } catch {
                // nothings to do
                print(error)
            }

            return .just(response)
        }
    }
}


public extension TargetType {

    /// 直接进行网络请求
    func request() -> Single<Response> {
        return xtProvider.rx.request(.target(self))
    }

    /// 使用时间缓存策略, 内存中有数据就不请求网络
    func memoryCacheIn(_ seconds: TimeInterval = 180) -> Single<CacheTimeTargetTuple> {
        return Single.just((seconds, self))
    }

    /// 读取磁盘缓存, 一般用于启动时先加载数据, 而后真正的读取网络数据
    func onStorage<T: Codable>(_ type: T.Type, atKeyPath keyPath: String = "", onDisk: ((T) -> ())?) -> OnDiskStorage<Self, T> {
        if let storage = readDiskStorage(type) { onDisk?(storage) }

        return OnDiskStorage(target: self, keyPath: keyPath)
    }

    /// 内存中缓存的数据
    fileprivate func cachedResponse() -> Response? {

        do {
            let cacheData = try kMemoryStroage.object(forKey: cacheKey)
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

    /// 从磁盘读取
    fileprivate func readDiskStorage<T: Codable>(_ type: T.Type) -> T? {
        do {
            let config = DiskConfig(name: "\(type.self)")
            let transformer = TransformerFactory.forCodable(ofType: type.self)
            let storage = try DiskStorage<String, T>.init(config: config, transformer: transformer)
            let model = try storage.object(forKey: cacheKey)
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
        try storage.setObject(model, forKey: cacheKey)
    }
}
#endif
