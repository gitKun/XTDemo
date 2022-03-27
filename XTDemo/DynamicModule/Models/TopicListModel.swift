//
/*
* ****************************************************************
*
* 文件名称 : TopicListModel
* 作   者 : Created by 坤
* 创建时间 : 2022/3/27 7:07 PM
* 文件描述 : 
* 注意事项 : Swift 5.0 已经支持 _ 直接转驼峰
* 版权声明 : 
* 修改历史 : 2022/3/27 初始版本
*
* ****************************************************************
*/

import Foundation


struct TopicListModel: Codable {
    var data = [TopicModel]()
    var errMsg: String?
    var errNo: Int = 0
}

struct TopicModel: Codable {
    // var adminUsers = [String]()
    var newShortMsgCount: Int = 0
    var topic: TopicModelInfo?
    var topicId: String?
    var userInteract: TopicModelUserInteract?
}

struct TopicModelInfo: Codable {
    // var adminIds = [String]()
    var attenderCount: Int = 0
    var cateId: String?
    var description: String?
    var followerCount: Int = 0
    var icon: String?
    var isRec: Bool = false
    var msgCount: Int = 0
    var notice: String?
    var recRank: Int = 0
    // var themeIds = [String]() // 话题
    var title: String?
    var topicId: String?
}

struct TopicModelUserInteract: Codable {
    var id: Int = 0
    var isCollect: Bool = false
    var isDigg: Bool = false
    var isFollow: Bool = false
    var omitempty: Int = 0
    var userId: Int = 0
}
