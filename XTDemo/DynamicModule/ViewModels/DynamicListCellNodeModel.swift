//
/*
* ****************************************************************
*
* 文件名称 : DynamicListCellNodeModel
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:29 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import RxSwift


protocol DynamicListCellNodeModelInputs {

    func configure(with model: DynamicListModel)

    func likeButtonAction(isLike: Bool)

    func reloadDiggUesrs(_ users: [AuthorUserInfo])

    func reloadLikeCount(_ count: Int)
}

protocol DynamicListCellNodeModelOutputs {

    var avatarUrl: Observable<URL?> { get }
    var nickname: Observable<NSAttributedString> { get }
    var position: Observable<NSAttributedString> { get }
    var recommendContent: Observable<NSAttributedString> { get }
    var imageList: Observable<[String]> { get }
    var hiddenImageList: Observable<Void> { get }
    var hotComment: Observable<HotComment> { get }
    var hiddenHotComment: Observable<Void> { get }
    var topicTitle: Observable<String> { get }
    var hiddenTopic: Observable<Void> { get }
    var digUsers: Observable<[AuthorUserInfo]> { get }
    var hiddenDigUsers: Observable<Void> { get }
    var commentCount: Observable<String> { get }
    var likeButton: Observable<(String, UIImage?, UIImage?)> { get }

    var changeLikeStatus: Observable<Bool> { get }
    var digged: Observable<AuthorUserInfo> { get }
    var unDigged: Observable<Void> { get }
    var reloadDiggCount: Observable<String> { get }
}

protocol DynamicListCellNodeModelType {
    var input: DynamicListCellNodeModelInputs { get }
    var output: DynamicListCellNodeModelOutputs { get }
}

final class DynamicListCellNodeModel: DynamicListCellNodeModelType, DynamicListCellNodeModelInputs, DynamicListCellNodeModelOutputs {

// MARK: - 属性

    private let disposeBag = DisposeBag()
    private let avatarImageSubject = PublishSubject<URL?>()
    private let nicknameSubject = PublishSubject<NSAttributedString>()
    private let positionSubject = PublishSubject<NSAttributedString>()
    private let recommendContentSubject = PublishSubject<NSAttributedString>()
    private let imageListSubject = PublishSubject<[String]>()
    private let hotShortSubject = PublishSubject<HotComment?>()
    private let circleTagSubject = PublishSubject<String?>()
    private let digUesrSubject = PublishSubject<[AuthorUserInfo]>()
    private let commentCountSubject = PublishSubject<String>()
    private let likeInfoSubject = PublishSubject<(String, UIImage?, UIImage?)>()

// MARK: - 生命周期

    init() {

        self.avatarUrl = self.avatarImageSubject.asObserver()
        self.nickname = self.nicknameSubject.asObserver()
        self.position = self.positionSubject.asObserver()
        self.recommendContent = self.recommendContentSubject.asObserver()
        self.imageList = self.imageListSubject.filter { !$0.isEmpty }
        self.hiddenImageList = self.imageListSubject.filter { $0.isEmpty }.map { _ in () }
        self.hotComment = self.hotShortSubject.filter { $0 != nil && $0!.commentInfo != nil }.map { $0! }
        self.hiddenHotComment = self.hotShortSubject.filter { $0 == nil || $0!.commentInfo == nil }.map { _ in () }
        self.topicTitle = self.circleTagSubject.filter { $0 != nil && !$0!.isEmpty }.map { $0! }
        self.hiddenTopic = self.circleTagSubject.filter { $0 == nil || $0!.isEmpty  }.map { _ in () }
        self.digUsers = self.digUesrSubject.filter { !$0.isEmpty }
        self.hiddenDigUsers = self.digUesrSubject.filter { $0.isEmpty }.map { _ in () }
        self.commentCount = self.commentCountSubject.asObserver()
        self.likeButton = self.likeInfoSubject.asObserver()

        self.changeLikeStatus = self.changeLikeStatusSubject.asObserver()
        self.digged = self.diggSubject.asObservable()
        self.unDigged = self.unDiggSubject.asObserver()
        self.reloadDiggCount = self.reloadLikeCountSubject.asObserver()
    }

// MARK: - input

    func configure(with model: DynamicListModel) {
        if let remote = model.authorUserInfo?.avatarLarge {
            avatarImageSubject.onNext(URL(string: remote))
        } else {
            avatarImageSubject.onNext(nil)
        }

        showNickname(model.authorUserInfo?.userName ?? "")
        showSubTitle(with: model.authorUserInfo?.jobTitle, time: model.msgInfo?.ctime)
        showComment(content: model.msgInfo?.content)

        imageListSubject.onNext(model.wrappedPictureList)

        hotShortSubject.onNext(model.hotComment)

        circleTagSubject.onNext(model.topic?.title)

        digUesrSubject.onNext(model.diggUser ?? [])

        let commentCount = model.msgInfo?.commentCount.jjStringValue ?? ""
        commentCountSubject.onNext(commentCount)

        let likeButtonType = LikeButtonType(rawValue: model.topic?.topicId.jjStringValue ?? "like") ?? .like
        let likeCount = model.msgInfo?.diggCount.jjStringValue ?? ""
        likeInfoSubject.onNext((likeCount, likeButtonType.normalImage, likeButtonType.selectedImage))

    }

    private let changeLikeStatusSubject = PublishSubject<Bool>()
    private let diggSubject = PublishSubject<AuthorUserInfo>()
    private let unDiggSubject = PublishSubject<Void>()
    func likeButtonAction(isLike: Bool) {
        // Note: - 这里要根据产品设计进行交互; 例如这里直接修改点赞状态在发送到网络
        // DONE: - 不再拆分成点赞后 inputs,直接返回
        // FIXED: - 拆分出了 DataSource, VM 中只做数据包装不做 model 的存储
        changeLikeStatusSubject.onNext(!isLike)
        if isLike {
            unDiggSubject.onNext(())
        } else {
            let user = AuthorUserInfo(avatar: "https://p6-passport.byteacctimg.com/img/user-avatar/ff972697d827eaa236f21985670fe0fa~300x300.image")
            diggSubject.onNext(user)
        }

        // 这里模仿网络请求
        Observable<Void>.just(()).delay(.milliseconds(500), scheduler: MainScheduler.asyncInstance).subscribe(onNext: { _ in
            //  点赞成功. 失败不作处理!
        }).disposed(by: disposeBag)
    }

    func reloadDiggUesrs(_ users: [AuthorUserInfo]) {
        digUesrSubject.onNext(users)
    }

    private let reloadLikeCountSubject = PublishSubject<String>()
    func reloadLikeCount(_ count: Int) {
        let countStr = count > 0 ? "\(count)" : ""
        reloadLikeCountSubject.onNext(countStr)
    }

// MARK: - Outputs

    let avatarUrl: Observable<URL?>
    let nickname: Observable<NSAttributedString>
    let position: Observable<NSAttributedString>
    let recommendContent: Observable<NSAttributedString>
    let hotComment: Observable<HotComment>
    let hiddenHotComment: Observable<Void>
    let imageList: Observable<[String]>
    let hiddenImageList: Observable<Void>
    let topicTitle: Observable<String>
    let hiddenTopic: Observable<Void>
    let digUsers: Observable<[AuthorUserInfo]>
    let hiddenDigUsers: Observable<Void>
    let commentCount: Observable<String>
    let likeButton: Observable<(String, UIImage?, UIImage?)>

    let changeLikeStatus: Observable<Bool>
    let digged: Observable<AuthorUserInfo>
    let unDigged: Observable<Void>
    let reloadDiggCount: Observable<String>

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
        nicknameSubject.onNext(attStr)
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
        positionSubject.onNext(attStr)
    }

    func showComment(content: String?) {
        guard let content = content else {
            return recommendContentSubject.onNext(NSAttributedString(string: ""))
        }

        /*
        // FIXED: - 已经抽取到 EmojiAttributedProvider 中
        let resultAttStr = NSMutableAttributedString(string: contnent, attributes: attr)
        */

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

            self.recommendContentSubject.onNext(resultAttStr)
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
