//
/*
* ****************************************************************
*
* 文件名称 : DynamicListModel
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


struct XTListResultModel: Codable {

    let count : Int?
    let cursor : String?
    let data : [DynamicListModel]?
    let errMsg : String?
    let errNo : Int?
    let hasMore : Bool

    enum CodingKeys: String, CodingKey {
        case count = "count"
        case cursor = "cursor"
        case data = "data"
        case errMsg = "err_msg"
        case errNo = "err_no"
        case hasMore = "has_more"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
        cursor = try values.decodeIfPresent(String.self, forKey: .cursor)
        data = try values.decodeIfPresent([DynamicListModel].self, forKey: .data)
        errMsg = try values.decodeIfPresent(String.self, forKey: .errMsg)
        errNo = try values.decodeIfPresent(Int.self, forKey: .errNo)
        hasMore = (try? values.decodeIfPresent(Bool.self, forKey: .hasMore)) ?? false
    }

    init() {
        self.count = 0
        self.cursor = nil
        self.data = nil
        self.errMsg = "No data!"
        self.errNo = 404
        self.hasMore = false
    }
}

struct CurcosInfoModel: Codable {
    let point: String?
    var length: Int?

    enum CodingKeys: String, CodingKey {
        case point = "v"
        case length = "i"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        point = try values.decodeIfPresent(String.self, forKey: .point)
        length = try values.decodeIfPresent(Int.self, forKey: .length)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(point, forKey: .point)
        try container.encodeIfPresent(length, forKey: .length)
    }
}

extension XTListResultModel {

    var cursorInfoSting: String {
        guard let cursor = cursor else { return "" }

        guard let jsonData = Data(base64Encoded: cursor, options: .ignoreUnknownCharacters) else { return "" }
        let jsonDecoder = JSONDecoder()

        guard var infoModel = try? jsonDecoder.decode(CurcosInfoModel.self, from: jsonData) else {
            return ""
        }

        let nextLength = (infoModel.length ?? 0) + (self.data?.count ?? 0)
        infoModel.length = nextLength

        let jsonEncoder = JSONEncoder()
        guard let encodData = try? jsonEncoder.encode(infoModel) else { return "" }
        return encodData.base64EncodedString()
    }
}

final class DynamicListModel : Codable {

    let authorUserInfo : AuthorUserInfo?
    var diggUser : [AuthorUserInfo]?
    let hotComment : HotComment?
    var msgInfo : DynamicListMegInfoMdoel?
    let msgId : String?
    let topic : Topic?
    var userInteract : UserInteractModel?

    var wrappedPictureList: [String] {
        return msgInfo?.picList ?? []
    }

    enum CodingKeys: String, CodingKey {
        case authorUserInfo = "author_user_info"
        case diggUser = "digg_user"
        case hotComment = "hot_comment"
        case msgInfo = "msg_Info"
        case msgId = "msg_id"
        case topic
        case userInteract = "user_interact"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        authorUserInfo = try values.decodeIfPresent(AuthorUserInfo.self, forKey: .authorUserInfo)
        diggUser = try values.decodeIfPresent([AuthorUserInfo].self, forKey: .diggUser)
        hotComment = try values.decodeIfPresent(HotComment.self, forKey: .hotComment)
        msgInfo = try values.decodeIfPresent(DynamicListMegInfoMdoel.self, forKey: .msgInfo)
        msgId = try values.decodeIfPresent(String.self, forKey: .msgId)
        topic = try values.decodeIfPresent(Topic.self, forKey: .topic)
        userInteract = try values.decodeIfPresent(UserInteractModel.self, forKey: .userInteract)
    }

}

struct HotComment: Codable {

    let commentId : String?
    let commentInfo : CommentInfo?
    let isAuthor : Bool?


    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case commentInfo = "comment_info"
        case isAuthor = "is_author"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        commentId = try values.decodeIfPresent(String.self, forKey: .commentId)
        commentInfo = try values.decodeIfPresent(CommentInfo.self, forKey: .commentInfo)
        isAuthor = try values.decodeIfPresent(Bool.self, forKey: .isAuthor)
    }

    struct CommentInfo: Codable {

        let commentContent : String?
        let diggCount : Int?

        enum CodingKeys: String, CodingKey {
            case commentContent = "comment_content"
            case diggCount = "digg_count"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            commentContent = try values.decodeIfPresent(String.self, forKey: .commentContent)
            diggCount = try values.decodeIfPresent(Int.self, forKey: .diggCount)
        }
    }
}

struct AuthorUserInfo : Codable {

    let avatarLarge : String?

    /// 某国企
    let company : String?

    /// 社会我瓜哥，人狠话不多😎 微信：anthony1453，你懂我意思吧🤘
    let descriptionField : String?

    /// 1
    let favorableAuthor : Int?

    /// 0
    let isLogout : Int?

    /// false
    let isfollowed : Bool?

    /// 日掘一金
    let jobTitle : String?

    /// 6
    let level : Int?

    /// 1521379823340792
    let userId : String?

    /// 掘金安东尼
    let userName : String?

    enum CodingKeys: String, CodingKey {
        case avatarLarge = "avatar_large"
        case company = "company"
        case descriptionField = "description"
        case favorableAuthor = "favorable_author"
        case isLogout = "is_logout"
        case isfollowed = "isfollowed"
        case jobTitle = "job_title"
        case level = "level"
        case userId = "user_id"
        case userName = "user_name"
    }

    init(avatar: String) {
        self.avatarLarge = avatar
        self.company = nil
        self.descriptionField = nil
        self.favorableAuthor = nil
        self.isLogout = nil
        self.isfollowed = nil
        self.jobTitle = nil
        self.level = nil
        self.userId = nil
        self.userName = nil
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        avatarLarge = try values.decodeIfPresent(String.self, forKey: .avatarLarge)
        company = try values.decodeIfPresent(String.self, forKey: .company)
        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
        favorableAuthor = try values.decodeIfPresent(Int.self, forKey: .favorableAuthor)
        isLogout = try values.decodeIfPresent(Int.self, forKey: .isLogout)
        isfollowed = try values.decodeIfPresent(Bool.self, forKey: .isfollowed)
        jobTitle = try values.decodeIfPresent(String.self, forKey: .jobTitle)
        level = try values.decodeIfPresent(Int.self, forKey: .level)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        userName = try values.decodeIfPresent(String.self, forKey: .userName)
    }
}

struct DynamicListMegInfoMdoel : Codable {

    /// 评论数
    let commentCount : Int?

    /// 内容
    let content : String?

    /// 创建时间
    let ctime : String?

    /// 点赞数
    var diggCount : Int?

    /// 数据库主键
    let cId : Int?

    /// 沸点id
    let msgId : String?

    /// 后台审核结束时间
    let mtime : String?

    /// 图片列表
    let picList : [String]?

    /// 修正时间
    let rtime : String?

    /// 话题 id
    let topicId : String?


    enum CodingKeys: String, CodingKey {
        case commentCount = "comment_count"
        case content = "content"
        case ctime = "ctime"
        case diggCount = "digg_count"
        case cId = "id"
        case msgId = "msg_id"
        case mtime = "mtime"
        case picList = "pic_list"
        case rtime = "rtime"
        case topicId = "topic_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        commentCount = try values.decodeIfPresent(Int.self, forKey: .commentCount)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        ctime = try values.decodeIfPresent(String.self, forKey: .ctime)
        diggCount = try values.decodeIfPresent(Int.self, forKey: .diggCount)
        cId = try values.decodeIfPresent(Int.self, forKey: .cId)
        msgId = try values.decodeIfPresent(String.self, forKey: .msgId)
        mtime = try values.decodeIfPresent(String.self, forKey: .mtime)
        picList = try values.decodeIfPresent([String].self, forKey: .picList)
        rtime = try values.decodeIfPresent(String.self, forKey: .rtime)
        topicId = try values.decodeIfPresent(String.self, forKey: .topicId)
    }
}

struct Topic : Codable {

    let cateId : String?
    let descriptionField : String?
    let icon : String?
    let notice : String?
    let title : String?
    let topicId : String?

    enum CodingKeys: String, CodingKey {
        case cateId = "cate_id"
        case descriptionField = "description"
        case icon = "icon"
        case notice = "notice"
        case title = "title"
        case topicId = "topic_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cateId = try values.decodeIfPresent(String.self, forKey: .cateId)
        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
        notice = try values.decodeIfPresent(String.self, forKey: .notice)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        topicId = try values.decodeIfPresent(String.self, forKey: .topicId)
    }

}

struct UserInteractModel : Codable {

    let isCollect : Bool?

    /// 标记自己是否点赞过此人
    var isDigg : Bool?

    /// 标记是否关注了作者
    var isFollow : Bool?
    let omitempty : Int?
    let userId : Int?

    enum CodingKeys: String, CodingKey {
        case isCollect = "is_collect"
        case isDigg = "is_digg"
        case isFollow = "is_follow"
        case omitempty = "omitempty"
        case userId = "user_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isCollect = try values.decodeIfPresent(Bool.self, forKey: .isCollect)
        isDigg = try values.decodeIfPresent(Bool.self, forKey: .isDigg)
        isFollow = try values.decodeIfPresent(Bool.self, forKey: .isFollow)
        omitempty = try values.decodeIfPresent(Int.self, forKey: .omitempty)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
    }
}


// MARK: - Model 提供的操作

extension DynamicListModel {

    func appendDigger(with avatar: String) {
        let user = AuthorUserInfo(avatar: avatar)
        self.appendDigger(user)
    }

    func appendDigger(_ user: AuthorUserInfo) {
        var users = self.diggUser ?? []
        users.append(user)
        self.diggUser = users
    }

    func popLastDigger() -> AuthorUserInfo? {
        guard var users = self.diggUser, !users.isEmpty else { return nil }
        let digger = users.popLast()
        self.diggUser = users
        return digger
    }

    func diggdynamic() {
        self.userInteract?.isDigg = true
        let count = self.msgInfo?.diggCount ?? 0
        self.msgInfo?.diggCount = count + 1
    }

    func unDiggdynamic() {
        self.userInteract?.isDigg = false
        let coun = self.msgInfo?.diggCount ?? 1
        self.msgInfo?.diggCount = coun - 1
    }
}
