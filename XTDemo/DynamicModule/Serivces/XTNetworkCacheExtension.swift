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
import Moya
import RxSwift
import Cache

/// 实际发送网络请求的 provider
private let xtProvider = MoyaProvider<MultiTarget>()


// FIXED: - 内部不再需要使用具体的类型
//private let kDynamicProvider = MoyaProvider<DynamicNetworkService>()


/// 替换现有的 plugins
///
/// Node: - 会涉及到 provider 的重新创建, 待定方法, 暂无实现!
///
/// - Parameter plugins: plugin 数组
public func changePlugins(_ plugins: [Moya.PluginType]) {}


public typealias CacheTimeTargetTuple = (cacheTime: TimeInterval, target: TargetType)
public typealias CacheTimeResponseTuple = (cacheTime: TimeInterval, target: TargetType)

extension ObservableType where Element == CacheTimeTargetTuple {

    public func request() -> Observable<Response> {
        return self.flatMap { tuple -> Observable<Response> in
            let target = tuple.target

            if let response = target.cachedResponse() {
                return .just(response)
            }

            let responseRquest = target.request().memoryCacheIn(second: tuple.cacheTime)

            return .just(Response.init(statusCode: 200, data: Data()))
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Moya.Response {

    fileprivate func memoryCacheIn(second: TimeInterval) -> Single<Response>  {

        return flatMap { response in
            // TODO: - cache 逻辑需要补充
            return .just(response)
        }
    }
}

//extension ObservableType where Element == Moya.Response {
//
//    func cachedResponse
//
//}

public extension TargetType {

    /// 直接进行网络请求
    func request() -> Single<Response> {
        return xtProvider.rx.request(.target(self))
    }

    /// 设置内存缓存的时间, 过时之前不发送网络请求
    func memoryCacheIn(seconds: TimeInterval) -> Observable<CacheTimeTargetTuple> {
        return Observable.just((seconds, self))
    }

    /// 内存中缓存的数据
    fileprivate func cachedResponse() -> Response? {

        // MemoryConfig(expiry: .seconds(3*60), countLimit: 3, totalCostLimit: 0)
        let memoryConfig = MemoryConfig.init()
        let stroage = MemoryStorage<String, Moya.Response>(config: memoryConfig)

        do {
            let cacheData = try stroage.object(forKey: cacheKey)
            return cacheData
        } catch {
            print(error)
            return nil
        }
    }

}

// MARK: - 缓存相关

extension TargetType {

    /// 缓存的 key
    var cacheKey: String {
        let key = "\(method)\(URL(target: self).absoluteString)\(self.path)?\(task.parameters)"
        return key.sha256
    }

    /// 缓存
    var cache: Observable<Self> {
        return Observable.just(self)
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
