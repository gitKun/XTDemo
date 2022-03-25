//
/*
* ****************************************************************
*
* 文件名称 : DynamicListParam
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:39 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation

enum SordType: Int {
    case hot = 200
    case new = 300
}

enum IdType: Int {
    case recommend = 4
}

struct DynamicListParam {

    /// 上次的位置, 默认为 0
    let cursor: String
    let limit: Int
    let sortType: SordType
    let idType: IdType

    init(cursor: String, limit: Int = 20, sortType: SordType = .hot, idType: IdType = .recommend) {
        self.cursor = cursor
        self.limit = limit
        self.sortType = sortType
        self.idType = idType
    }

    func toJsonDict() -> [String: Any] {
        return ["cursor": cursor, "limit": limit, "sort_type": sortType.rawValue, "id_type": idType.rawValue]
    }
}
