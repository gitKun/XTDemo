//
/*
* ****************************************************************
*
* 文件名称 : DynamicDisplayModel
* 作   者 : Created by 坤
* 创建时间 : 2022/3/29 8:08 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/29 初始版本
*
* ****************************************************************
*/

import Foundation

enum DynamicDisplayType {
    case dynamic(DynamicListModel)
    case topicList([TopicModel])
}


extension DynamicDisplayType: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .dynamic(let dynamicListModel):
            return dynamicListModel.msgId ?? "DynamicListModel"
        case .topicList(let array):
            return "TopicModel count: \(array.count)"
        }
    }
}


struct DynamicDisplayModel {

    var cursor: String? = nil
    var errMsg: String? = nil
    var errNo: Int? = nil
    var displayModels: [DynamicDisplayType] = []
    var hasMore: Bool = false

    var dynamicsCount: Int = 0

    init(from wrapped: XTListResultModel) {
        self.cursor = wrapped.cursor
        self.errMsg = wrapped.errMsg
        self.errNo = wrapped.errNo
        self.hasMore = wrapped.hasMore

        self.dynamicsCount = wrapped.data?.count ?? 0
    }

    init() {}

    mutating func updateDisplayModels(from list: [DynamicDisplayType]) {
        self.displayModels = list
    }

    var cursorInfoSting: String {
        guard let cursor = cursor else { return "" }

        guard let jsonData = Data(base64Encoded: cursor, options: .ignoreUnknownCharacters) else { return "" }
        let jsonDecoder = JSONDecoder()

        guard var infoModel = try? jsonDecoder.decode(CurcosInfoModel.self, from: jsonData) else {
            return ""
        }

        let nextLength = (infoModel.length ?? 0) + dynamicsCount
        infoModel.length = nextLength

        let jsonEncoder = JSONEncoder()
        guard let encodData = try? jsonEncoder.encode(infoModel) else { return "" }
        return encodData.base64EncodedString()
    }
}
