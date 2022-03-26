//
/*
* ****************************************************************
*
* 文件名称 : XTNetworkService
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:46 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import Moya
import RxSwift

typealias JJNetworkParam = [String: Any]

private let kDynamicProvider = MoyaProvider<XTNetworkService>()

private let provider = MoyaProvider<MultiTarget>()

public extension TargetType {

    func request() -> Single<Response> {
        return provider.rx.request(.target(self))
    }
}



enum XTNetworkService {
    case list(param: JJNetworkParam)
    case topicListRecommend
}

private let jjBaseUrl = "https://api.juejin.cn"


extension XTNetworkService: TargetType {

    var headers: [String : String]? {
        var tokenHeader: [String: String] = [:]

        tokenHeader["Content-Type"] = "application/json"
        tokenHeader["User-Agent"] = "PostmanRuntime/7.28.4"
        tokenHeader["Accept-Encoding"] = "gzip, deflate, br"
        tokenHeader["Connection"] = "keep-alive"

        return tokenHeader
    }

    var baseURL: URL {
        return URL(string: jjBaseUrl)!
    }

    var path: String {
        switch self {
        case .list(_):
            return "/recommend_api/v1/short_msg/hot"
        case .topicListRecommend:
            return "/tag_api/v1/topic/list_by_follow_rec"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list(_):
            return Method.post
        case .topicListRecommend:
            return Method.post
        }
    }

    var task: Task {
        switch self {
        case .list(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        case .topicListRecommend:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        }
    }

    /// mock数据，调试的使用，建议使用Swift5的特性，#字符串#，这样写JSON字符串更清爽
    var sampleData: Data {
        switch self {
        default:
            let jsonString = #"{"code": 0}"#
            return jsonString.data(using: .utf8) ?? Data()
        }
    }

}
