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


private let xtProvider = MoyaProvider<MultiTarget>()
private let kDynamicProvider = MoyaProvider<DynamicNetworkService>()


extension ObservableType where Element: TargetType {

//    public func request() -> Observable<Response> {
//        return flatMap { target -> Observable<Response> in
//            let source = target.request()//.storeCachedResponse(for: target).asObservable()
//            if let response = target.cachedResponse {
//                return source.startWith(response)
//            }
//            return source
//        }
//    }
}

public extension TargetType {

    func request() -> Single<Response> {
        return xtProvider.rx.request(.target(self))
    }

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

