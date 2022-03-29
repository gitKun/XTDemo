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
