//
/*
* ****************************************************************
*
* 文件名称 : DynamicListCellCombineNodeModel
* 作   者 : Created by 坤
* 创建时间 : 2022/4/11 13:23
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/11 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import Combine

protocol DynamicListCellNodeModelInputs {

    func configure(with model: DynamicListModel)

    func likeButtonAction(isLike: Bool)

    func reloadDiggUesrs(_ users: [AuthorUserInfo])

    func reloadLikeCount(_ count: Int)
}

protocol DynamicListCellNodeModelOutputs {

    var avatarUrl: AnyPublisher<URL?, Never> { get }
    var nickname: AnyPublisher<NSAttributedString, Never> { get }
    var position: AnyPublisher<NSAttributedString, Never> { get }
    var recommendContent: AnyPublisher<NSAttributedString, Never> { get }
    var imageList: AnyPublisher<[String], Never> { get }
    var hiddenImageList: AnyPublisher<Void, Never> { get }
    var hotComment: AnyPublisher<HotComment, Never> { get }
    var hiddenHotComment: AnyPublisher<Void, Never> { get }
    var topicTitle: AnyPublisher<String, Never> { get }
    var hiddenTopic: AnyPublisher<Void, Never> { get }
    var digUsers: AnyPublisher<[AuthorUserInfo], Never> { get }
    var hiddenDigUsers: AnyPublisher<Void, Never> { get }
    var commentCount: AnyPublisher<String, Never> { get }
    var likeButton: AnyPublisher<(String, UIImage?, UIImage?), Never> { get }

    var changeLikeStatus: AnyPublisher<Bool, Never> { get }
    var digged: AnyPublisher<AuthorUserInfo, Never> { get }
    var unDigged: AnyPublisher<Void, Never> { get }
    var reloadDiggCount: AnyPublisher<String, Never> { get }
}

protocol DynamicListCellNodeModelType {
    var input: DynamicListCellNodeModelInputs { get }
    var output: DynamicListCellNodeModelOutputs { get }
}


final class DynamicListCellNodeModel: DynamicListCellNodeModelType, DynamicListCellNodeModelInputs, DynamicListCellNodeModelOutputs {

    // @Published var avatarImageUrl: URL? = nil
    private let avatarImageSubject = PassthroughSubject<URL?, Never>()
    private let nicknameSubject = PassthroughSubject<NSAttributedString, Never>()
    private let positionSubject = PassthroughSubject<NSAttributedString, Never>()
    private let recommendContentSubject = PassthroughSubject<NSAttributedString, Never>()
    private let imageListSubject = PassthroughSubject<[String], Never>()
    private let hotShortSubject = PassthroughSubject<HotComment?, Never>()
    private let circleTagSubject = PassthroughSubject<String?, Never>()
    private let digUesrSubject = PassthroughSubject<[AuthorUserInfo], Never>()
    private let commentCountSubject = PassthroughSubject<String, Never>()
    private let likeInfoSubject = PassthroughSubject<(String, UIImage?, UIImage?), Never>()

    init() {
        self.avatarUrl = self.avatarImageSubject.eraseToAnyPublisher()
        self.nickname = self.nicknameSubject.eraseToAnyPublisher()
        self.position = self.positionSubject.eraseToAnyPublisher()
        self.recommendContent = self.recommendContentSubject.eraseToAnyPublisher()
        self.imageList = self.imageListSubject.filter { !$0.isEmpty }.eraseToAnyPublisher()
        self.hiddenImageList = self.imageListSubject.filter { $0.isEmpty }.map { _ in () }.eraseToAnyPublisher()
        self.hotComment = self.hotShortSubject.filter { $0 != nil && $0!.commentInfo != nil }.map { $0! }.eraseToAnyPublisher()
        self.hiddenHotComment = self.hotShortSubject.filter { $0 == nil || $0!.commentInfo == nil }.map { _ in () }.eraseToAnyPublisher()
        self.topicTitle = self.circleTagSubject.filter { $0 != nil && !$0!.isEmpty }.map { $0! }.eraseToAnyPublisher()
        self.hiddenTopic = self.circleTagSubject.filter { $0 == nil || $0!.isEmpty  }.map { _ in () }.eraseToAnyPublisher()
        self.digUsers = self.digUesrSubject.filter { !$0.isEmpty }.eraseToAnyPublisher()
        self.hiddenDigUsers = self.digUesrSubject.filter { $0.isEmpty }.map { _ in () }.eraseToAnyPublisher()
        self.commentCount = self.commentCountSubject.eraseToAnyPublisher()
        self.likeButton = self.likeInfoSubject.eraseToAnyPublisher()

        self.changeLikeStatus = self.changeLikeStatusSubject.eraseToAnyPublisher()
        self.digged = self.diggSubject.eraseToAnyPublisher()
        self.unDigged = self.unDiggSubject.eraseToAnyPublisher()
        self.reloadDiggCount = self.reloadLikeCountSubject.eraseToAnyPublisher()
    }

// MARK: - inputs

    func configure(with model: DynamicListModel) {
        if let remote = model.authorUserInfo?.avatarLarge {
            avatarImageSubject.send(URL(string: remote))
        } else {
            avatarImageSubject.send(nil)
        }

        showNickname(model.authorUserInfo?.userName ?? "")
        showSubTitle(with: model.authorUserInfo?.jobTitle, time: model.msgInfo?.ctime)
        showComment(content: model.msgInfo?.content)

        imageListSubject.send(model.wrappedPictureList)

        hotShortSubject.send(model.hotComment)

        circleTagSubject.send(model.topic?.title)

        digUesrSubject.send(model.diggUser ?? [])

        let commentCount = model.msgInfo?.commentCount.jjStringValue ?? ""
        commentCountSubject.send(commentCount)

        let likeButtonType = LikeButtonType(rawValue: model.topic?.topicId.jjStringValue ?? "like") ?? .like
        let likeCount = model.msgInfo?.diggCount.jjStringValue ?? ""
        likeInfoSubject.send((likeCount, likeButtonType.normalImage, likeButtonType.selectedImage))
    }

    private let changeLikeStatusSubject = PassthroughSubject<Bool, Never>()
    private let diggSubject = PassthroughSubject<AuthorUserInfo, Never>()
    private let unDiggSubject = PassthroughSubject<Void, Never>()
    func likeButtonAction(isLike: Bool) {
        changeLikeStatusSubject.send(!isLike)
        if isLike {
            unDiggSubject.send(())
        } else {
            let user = AuthorUserInfo(avatar: "https://p6-passport.byteacctimg.com/img/user-avatar/ff972697d827eaa236f21985670fe0fa~300x300.image")
            diggSubject.send(user)
        }
    }

    func reloadDiggUesrs(_ users: [AuthorUserInfo]) {
        digUesrSubject.send(users)
    }

    private let reloadLikeCountSubject = PassthroughSubject<String, Never>()
    func reloadLikeCount(_ count: Int) {
        let countStr = count > 0 ? "\(count)" : ""
        reloadLikeCountSubject.send(countStr)
    }

// MARK: - Outputs

    let avatarUrl: AnyPublisher<URL?, Never>
    let nickname: AnyPublisher<NSAttributedString, Never>
    let position: AnyPublisher<NSAttributedString, Never>
    let recommendContent: AnyPublisher<NSAttributedString, Never>
    let hotComment: AnyPublisher<HotComment, Never>
    let hiddenHotComment: AnyPublisher<Void, Never>
    let imageList: AnyPublisher<[String], Never>
    let hiddenImageList: AnyPublisher<Void, Never>
    let topicTitle: AnyPublisher<String, Never>
    let hiddenTopic: AnyPublisher<Void, Never>
    let digUsers: AnyPublisher<[AuthorUserInfo], Never>
    let hiddenDigUsers: AnyPublisher<Void, Never>
    let commentCount: AnyPublisher<String, Never>
    let likeButton: AnyPublisher<(String, UIImage?, UIImage?), Never>

    let changeLikeStatus: AnyPublisher<Bool, Never>
    let digged: AnyPublisher<AuthorUserInfo, Never>
    let unDigged: AnyPublisher<Void, Never>
    let reloadDiggCount: AnyPublisher<String, Never>

// MARK: - DynamicListCellNodeModelType

    var input: DynamicListCellNodeModelInputs { self }
    var output: DynamicListCellNodeModelOutputs { self }

}


// MARK: - 数据组装

fileprivate extension DynamicListCellNodeModel {

    func showNickname(_ name: String) {
        let nicknameAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor : UIColor.XiTu.nickName,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium) //UIFont.lfSystemMediumFont(size: 15)
        ]
        let attStr = NSAttributedString(string: name, attributes: nicknameAttr)
        nicknameSubject.send(attStr)
    }

    func showSubTitle(with jobTitle: String?, time: String?) {
        var value = ""
        if let jobTitle = jobTitle, !jobTitle.isEmpty {
            value.append(jobTitle)
            value.append("•") // ・
        }
        if let time = time {
            let timeString = DateUtil.jjShowTimeFormTimestampString(time)
            value.append(timeString)
        }

        let positionAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor : UIColor.XiTu.position,
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)//UIFont.lfSystemFont(size: 11)
        ]
        let attStr = NSAttributedString(string: value, attributes: positionAttr)
        positionSubject.send(attStr)
    }

    func showComment(content: String?) {
        guard let content = content else {
            recommendContentSubject.send(NSAttributedString(string: ""))
            return
        }

        DispatchQueue.global(qos: .default).async {
            let font = UIFont.systemFont(ofSize: 15, weight: .regular)
            let lineHeight: CGFloat = 21
            let paragraph = NSMutableParagraphStyle()
            paragraph.maximumLineHeight = lineHeight
            paragraph.minimumLineHeight = lineHeight
            paragraph.alignment = .justified
            // 首行缩进2字符
            // paragraph.firstLineHeadIndent = font.pointSize * 2
            // FIXME: - 对于 ASTextNode 会覆盖 truncationMode, 对于 ASTestNode2 则不起作用
            // paragraph.lineBreakMode = .byClipping

            let baselineOffset = (lineHeight  - font.lineHeight) / 4

            let attr: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.XiTu.shortContent,
                .font: font,
                .paragraphStyle: paragraph,
                .baselineOffset: baselineOffset
            ]

            // FIXME: - 对于使用 UITableViewCell 的情况, 请在 model 中添加缓存, 避免重复计算!!!
            let resultAttStr = EmojiAttributedProvider.shared.generateEmojiAttributedString(from: content, attributed: attr, imageHeihg: font.lineHeight)

            self.recommendContentSubject.send(resultAttStr)
        }
    }
}

/*
 6824710202734936077 -> 掘友请回答
 6824710202734936077 -> 树洞一下
 6931179346187321351 -> 理财交流圈
 */
fileprivate enum LikeButtonType: String {

    case like
    case fish = "6824710203301167112"
    case wealth = "682471020330116715"

    var selectedImage: UIImage? {
        switch self {
        case .like:
            return UIImage(named: "icon_dig_blue")
        case .fish:
            return UIImage(named: "icon_dig_fish")
        case .wealth:
            return UIImage(named: "icon_dig_wealth")
        }
    }

    var normalImage: UIImage? {
        switch self {
        case .like:
            return UIImage(named: "icon_undig")
        case .fish:
            return UIImage(named: "icon_undig_fish")
        case .wealth:
            return UIImage(named: "icon_undig_wealth")
        }
    }
}

fileprivate extension Optional /*where Wrapped == Int*/ {

    var jjStringValue: String? {
        switch self {
        case .none:
            return nil
        case .some(let wrapped):
            return "\(wrapped)"
        }
    }
}
