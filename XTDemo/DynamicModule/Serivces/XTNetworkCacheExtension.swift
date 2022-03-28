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

import Foundation
import CommonCrypto
import RxSwift
import Moya
import Cache
import Accelerate

/// 实际发送网络请求的 provider
private let xtProvider = MoyaProvider<MultiTarget>()


let kMemoryStroage: MemoryStorage<String, Any> = .init(config: MemoryConfig())


/// 替换现有的 plugins
///
/// Node: - 会涉及到 provider 的重新创建, 待定方法, 暂无实现!
///
/// - Parameter plugins: plugin 数组
public func changePlugins(_ plugins: [Moya.PluginType]) {}


// MARK: - 在内存中缓存

public typealias CacheTimeTargetTuple = (cacheTime: TimeInterval, target: TargetType)

extension PrimitiveSequence where Trait == SingleTrait, Element == CacheTimeTargetTuple {

    public func requeset() -> Single<Response> {
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

    /// 每个包裹的结构体都提供 request 方法, 方便后续链式调用时去除不想要的功能
    ///
    /// 如 `provider.memoryCacheIn(3*50).request()` 中去除 `.memoryCacheIn(3*50)` 仍能正常使用
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
    func memoryCacheIn(seconds: TimeInterval = 180) -> PrimitiveSequence<SingleTrait, CacheTimeTargetTuple> {
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

// MARK: - 缓存相关

extension TargetType {

    /// 缓存的 key
    var cacheKey: String {
        let key = "\(method)\(URL(target: self).absoluteString)\(self.path)?\(task.parameters)"
        return key.sha256
    }
}

extension Task {

    public var canCactch: Bool {
        switch self {
        case .requestPlain:
            fallthrough
        case .requestParameters(_, _):
            fallthrough
        case .requestCompositeData(_, _):
            fallthrough
        case .requestCompositeParameters(_ , _, _):
            return true
        default:
            return false
        }
    }

    public var parameters: String {
        switch self {
        case .requestParameters(let parameters, _):
            return parameters.sortedDescription
        case .requestCompositeData(_, let urlParameters):
            return urlParameters.sortedDescription
        case .requestCompositeParameters(let bodyParameters, _, let urlParameters):
            return bodyParameters.sortedDescription + urlParameters.sortedDescription
        default:
            return ""
        }
    }
}


// MARK: - Swift.Collection

private extension String {

    var sha256: String {
        guard let data = data(using: .utf8) else { return self }

        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            return CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &digest)
        }

        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// TODO: - 需要做测试 XCTest

private extension Optional {
    var stringValue: String {
        switch self {
        case .none:
            return ""
        case .some(let wrapped):
            return "\(wrapped)"
        }
    }
}

private extension Optional where Wrapped == Dictionary<String, Any> {
    var stringValue: String {
        switch self {
        case .none:
            return ""
        case .some(let wrapped):
            let allKeys = wrapped.keys.sorted()
            return allKeys.map { $0 + ":" + wrapped[$0].stringValue }.joined(separator: ",")
        }
    }
}

private extension Optional where Wrapped: Collection, Wrapped.Element: Comparable {
    var stringValue: String {
        switch self {
        case .none:
            return ""
        case .some(let wrapped):
            return wrapped.sorted().reduce("") { $0 + "\($1)" }
        }
    }
}

private extension Dictionary where Key == String {

    var sortedDescription: String {
        let allKeys = self.keys.sorted()
        return allKeys.map { $0 + ":" + self[$0].stringValue }.joined(separator: ",")
    }
}


// MAKR: - v 1.0 构思

// FIXED: - 内部不再需要使用具体的类型
// private let kDynamicProvider = MoyaProvider<DynamicNetworkService>()

// FIXED: - 这里废除下述方法, 网络请求更应该使用 Single 来传递, 所有对外接口保持一致
/*
extension TargetType {
    /// 设置内存缓存的时间, 过时之前不发送网络请求
    func memoryCacheIn(seconds: TimeInterval) -> Observable<CacheTimeTargetTuple> {
        return Observable.just((seconds, self))
    }
}

extension ObservableType where Element == CacheTimeTargetTuple {

    // FIXME: - 这里应该原样返回 Single<Response>, 相当于自己创建 Observer
    public func request() -> Observable<Response> {

        return flatMap { tuple -> Observable<Response> in
            let target = tuple.target

            if let response = target.cachedResponse() {
                return .just(response)
            }

            let cacheKey = target.cacheKey
            let seconds = tuple.cacheTime
            let response = target.request().flatMap { response -> Single<Moya.Response> in
                let memoryConfig = MemoryConfig(expiry: .seconds(seconds), countLimit: 3, totalCostLimit: 0)
                let stroage = MemoryStorage<String, Moya.Response>(config: memoryConfig)
                stroage.setObject(response, forKey: cacheKey)
                return .just(response)
            }

            return response.asObservable()
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element: Codable {

    public func storage() -> Single<Element> {
        let result = flatMap { model -> Single<Element> in
            let config = DiskConfig(name: "\(Element.self)")
            do {
                let transformer = TransformerFactory.forCodable(ofType: Element.self)
                let storage = try DiskStorage<String, Element>.init(config: config, transformer: transformer)
                try storage.setObject(model, forKey: "xxx")
            } catch {
                print(error)
            }
            return .just(model)
        }
        return result
    }
}
*/

/**
public protocol XTTargetType: TargetType {

    /// 设置内存缓存的时间, 如不返回则表示每次都从网络请求. 默认返回 nil
    ///
    /// 用来处理某些不需要每次刷新的数据, 如 推荐的话题列表
    var memoryCacheTimeInSeconds: TimeInterval? { get }

    /// 是否需要存储请求回来的数据
    var needStorageMapResult: Bool { get }

    /// 缓存的 key, 有默认实现, 但不能保证正确性, 如需缓存最好自行添加 key
    ///
    /// 内部使用的 method + baseUrl + path + task.paraneters 实现,
    /// 其中的 task.paraneters 在大多数非 param 创建的请求中默认返回 ""
    /// 对于 param 则采用了 sorted keys 后拼为字符串,
    /// 对于 value 为 Collection 时, 内部会判断 Element 是否为 Comparable
    /// 符合 Comparable 则排序后拼接为字符串, 否则直接合成字符串,
    /// 因此不能保证  cacheKey 的正确性
    var cacheKey: String { get }

    /// 内部会判断是否需要缓存, 外部应该使用此方法发起网络请求
    func request() -> Moya.Response
}

public extension XTTargetType {

    var cacheTimeInSeconds: TimeInterval? { return nil }

    var cacheKey: String {
        let key = "\(method)\(URL(target: self).absoluteString)\(self.path)?\(task.parameters)"
        return key.sha256
    }

    var needStorageMapResult: Bool { return false }
}
 */
