//
/*
* ****************************************************************
*
* 文件名称 : Moya+XTCache
* 作   者 : Created by 坤
* 创建时间 : 2022/4/9 22:33
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/9 初始版本
*
* ****************************************************************
*/

import Foundation
import Moya
import CommonCrypto


// MARK: - 缓存相关

extension TargetType {

    /// 缓存的 key
    var cacheKey: String {
        let key = "\(method)\(URL(target: self).absoluteString)\(self.path)?\(task.parameters)"
        return key.sha256
    }
}

extension Task {

    var canCactch: Bool {
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

    var parameters: String {
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

fileprivate extension String {

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

fileprivate extension Optional {
    var stringValue: String {
        switch self {
        case .none:
            return ""
        case .some(let wrapped):
            return "\(wrapped)"
        }
    }
}

fileprivate extension Optional where Wrapped == Dictionary<String, Any> {
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

fileprivate extension Optional where Wrapped: Collection, Wrapped.Element: Comparable {
    var stringValue: String {
        switch self {
        case .none:
            return ""
        case .some(let wrapped):
            return wrapped.sorted().reduce("") { $0 + "\($1)" }
        }
    }
}

fileprivate extension Dictionary where Key == String {

    var sortedDescription: String {
        let allKeys = self.keys.sorted()
        return allKeys.map { $0 + ":" + self[$0].stringValue }.joined(separator: ",")
    }
}
