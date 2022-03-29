//
/*
* ****************************************************************
*
* 文件名称: TopicListModel
* 作   者: Created by 坤
* 创建时间: 2022/3/27 7:07 PM
* 文件描述:
* 注意事项: Swift 5.0 已经支持 _ 直接转驼峰, 验证为错误至少 5.3 以后
* 版权声明:
* 修改历史: 2022/3/27 初始版本
*
* ****************************************************************
*/

import Foundation

struct TopicListModel: Codable {

    let data: [TopicModel]?
    let errMsg: String?
    let errNo: Int

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case errMsg = "err_msg"
        case errNo = "err_no"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = (try? values.decodeIfPresent([TopicModel].self, forKey: .data)) ?? []
        errMsg = try values.decodeIfPresent(String.self, forKey: .errMsg)
        errNo = try values.decode(Int.self, forKey: .errNo)
    }

    init() {
        self.data = nil
        self.errMsg = "No data!"
        self.errNo = 0
    }
}

struct TopicModel: Codable {

    let newShortMsgCount: Int
    let topicInfo: TopicInfoModel?
    let topicId: String?
    let userInteract: TopicModelUserInteract?

    enum CodingKeys: String, CodingKey {
        case newShortMsgCount = "new_short_msg_count"
        case topicInfo = "topic"
        case topicId = "topic_id"
        case userInteract = "userInteract"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        newShortMsgCount = try values.decode(Int.self, forKey: .newShortMsgCount)
        topicInfo = try values.decodeIfPresent(TopicInfoModel.self, forKey: .topicInfo)
        topicId = try values.decodeIfPresent(String.self, forKey: .topicId)
        userInteract = try values.decodeIfPresent(TopicModelUserInteract.self, forKey: .userInteract)
    }
}

struct TopicInfoModel: Codable {

    var attenderCount: Int
    var cateId: String?
    var descriptionField: String?
    var followerCount: Int
    var icon: String?
    var isRec: Bool = false
    var msgCount: Int
    var notice: String?
    var recRank: Int
    var title: String?
    var topicId: String?

    enum CodingKeys: String, CodingKey {
        case attenderCount = "attender_count"
        case cateId = "cate_id"
        case descriptionField = "description"
        case followerCount = "follower_count"
        case icon = "icon"
        case isRec = "is_rec"
        case msgCount = "msg_count"
        case notice = "notice"
        case recRank = "rec_rank"
        case title = "title"
        case topicId = "topic_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        attenderCount = try values.decode(Int.self, forKey: .attenderCount)
        cateId = try values.decodeIfPresent(String.self, forKey: .cateId)
        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
        followerCount = try values.decode(Int.self, forKey: .followerCount)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
        isRec = try values.decode(Bool.self, forKey: .isRec)
        msgCount = try values.decode(Int.self, forKey: .msgCount)
        notice = try values.decodeIfPresent(String.self, forKey: .notice)
        recRank = (try? values.decodeIfPresent(Int.self, forKey: .recRank)) ?? 0
        title = try values.decodeIfPresent(String.self, forKey: .title)
        topicId = try values.decodeIfPresent(String.self, forKey: .topicId)
    }
}

struct TopicModelUserInteract: Codable {

    var isCollect: Bool = false
    var isDigg: Bool = false
    var isFollow: Bool = false
    var omitempty: Int = 0
    var userId: Int = 0

    enum CodingKeys: String, CodingKey {
        case isCollect = "is_collect"
        case isDigg = "is_digg"
        case isFollow = "is_follow"
        case omitempty = "omitempty"
        case userId = "user_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isCollect = try values.decode(Bool.self, forKey: .isCollect)
        isDigg = try values.decode(Bool.self, forKey: .isDigg)
        isFollow = try values.decode(Bool.self, forKey: .isFollow)
        omitempty = try values.decode(Int.self, forKey: .omitempty)
        userId = try values.decode(Int.self, forKey: .userId)
    }
}
