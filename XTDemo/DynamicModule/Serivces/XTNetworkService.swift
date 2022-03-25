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

typealias JJNetworkParam = [String: Any]

let kDynamicProvider = MoyaProvider<XTNetworkService>()

enum XTNetworkService {
    case list(param: JJNetworkParam)
}

private let jjBaseUrl = "https://example.com"


/*
 Accept: application/json
 Accept-Encoding: gzip, deflate
 Connection: keep-alive
 Content-Length: 121
 Content-Type: application/json; encoding=utf-8
 Cookie: xxxxx
 Host: api.example.cn
 User-Agent: xitu 6.1.6 rv:6.1.6.1 (iPhone; iOS 15.3.1; zh_CN) Cronet
 X-Argus: xx/xx+x/x/x/x/x/x/x+x/x+x=
 X-Gorgon: x
 X-Khronos: x
 X-Ladon: x+x
 X-SS-Cookie: xxxx
 X-SS-STUB: xxxx
 passport-sdk-version: 5.13.3
 sdk-version: 2
 tt-request-time: 1647240642142
 x-Tt-Token: xxxxx
 x-vc-bdturing-sdk-version: 2.1.0-rc.7
 */


extension XTNetworkService: TargetType {

    var headers: [String : String]? {
        var tokenHeader: [String: String] = [:]

        switch self {
        case .list(_):
            tokenHeader["Content-Type"] = "application/json"
            tokenHeader["User-Agent"] = "PostmanRuntime/7.28.4"
            tokenHeader["Accept-Encoding"] = "gzip, deflate, br"
            tokenHeader["Connection"] = "keep-alive"
        }

        return tokenHeader
    }

    var baseURL: URL {
        return URL(string: jjBaseUrl)!
    }

    var path: String {
        switch self {
        case .list(_):
            return "/yourpath"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list(_):
            return Method.post
        }
    }

    var task: Task {
        switch self {
        case .list(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        }
    }

    /// mock数据，调试的使用，建议使用Swift5的特性，#字符串#，这样写JSON字符串更清爽
    var sampleData: Data {
        switch self {
        case .list(_):
            let jsonString = #"{"code": 0}"#
            return jsonString.data(using: .utf8) ?? Data()
        }
    }

}
