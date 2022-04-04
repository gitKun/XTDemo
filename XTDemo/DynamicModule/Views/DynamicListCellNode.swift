//
/*
* ****************************************************************
*
* 文件名称 : DynamicListCellNode
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:28 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import UIKit
import Foundation
import AsyncDisplayKit
import RxSwift
import Kingfisher


/// cell node subnode 事件处理
protocol DynamicListCellNodeDelegate {

    func listCellNode(_ cellNodel: DynamicListCellNode, selectedView: UIView, selectedImage at: Int, allImages: [String])

    func listCellNode(_ cellNodel: DynamicListCellNode, showDiggForMsg: String?)

    // TODO: - 需要点击头像, 分享 的时间传递
}


/**
 * 可优化点:
 *      1. 把 3 行显示的文本和 展开/隐藏 按钮,封装为一个控件, 内部重写 `override func layout()` 来提升新能.
 *      2. addSubnode 的判断!
 */


final class DynamicListCellNode: ASCellNode {

// MARK: - 属性

    internal var delegate: DynamicListCellNodeDelegate?

    private let viewModel: DynamicListCellNodeModelType = DynamicListCellNodeModel()
    private let disposeBag = DisposeBag()
    private let dataSource = DynamicListCellNodeDataSource()

// MARK: - 生命周期

    override init() {
        super.init()

        self.initizalizeUI()
        self.eventListen()
        self.bindViewModel()
    }

    // 已经进入展示状态, 进行 开始/创建动画, image展示, 等
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
    }

    // 已经结束展示, 进行 暂停/移除 动画, image 的内存回收, 等
    override func didExitDisplayState() {
        super.didExitDisplayState()
    }


// MARK: - UI element

    private lazy var bgContentNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.backgroundColor = .XiTu.cellContenBg
        node.isLayerBacked = true
        return node
    }()

    /// 头像, 大小 32
    private lazy var avatarNode: ASImageNode = {
        let node = ASImageNode()
        node.image = UIImage.init(named: "head_def")
        node.cornerRadius = 20
        node.clipsToBounds = true
        return node
    }()

    /// 昵称, 颜色 raba(r: 51, g: 51, b: 51) 字体 16 Med
    private lazy var nicknameNode: ASTextNode = {
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        node.truncationMode = .byTruncatingTail
        return node
    }()

    /// 职业和动态时间, rgba(r: 180, g: 180, b: 180)
    private lazy var positionNode: ASTextNode = {
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        node.truncationMode = .byTruncatingTail
        return node
    }()

    /// 动态的内容, 最多三行
    private lazy var shortContentNode: ASTextNode = {
        let node = ASTextNode()
        // FIXED: - 为了解决首次展示的数据文本过高出现剧烈的抖动问题 5 是最佳效果!
        node.maximumNumberOfLines = 4
        // FIXME: - 对 ASTextNode2 设置此属性为 byClipping 造成不换行, 但是在 ASTextNode 中则正常
        // node.truncationMode = .byClipping
        return node
    }()

    /// 更多/收起 按钮
    private lazy var showOrHiddenNode: ASButtonNode = {
        let node = ASButtonNode()
        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        node.setTitle("展开", with: font, with: .rgba(r: 88, g: 158, b: 255), for: .normal)
        node.setTitle("收起", with: font, with: .rgba(r: 88, g: 158, b: 255), for: .selected)
        node.contentHorizontalAlignment = .left
        return node
    }()

    /// 图片集
    private lazy var imgCollectionNode: ASCollectionNode = {
        let layout = UICollectionViewFlowLayout()
        let itemWidth = floor(111.sizeFromIphone6)
        let spaceBetweenItems = floor(5.sizeFromIphone6)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = spaceBetweenItems
        layout.minimumLineSpacing = spaceBetweenItems

        let collection = ASCollectionNode(collectionViewLayout: layout)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.alwaysBounceVertical = false
        collection.alwaysBounceHorizontal = false
        collection.delegate = self
        collection.dataSource = self.dataSource
        return collection
    }()

    /// 热评
    private lazy var hotShortNode: DynamicHotCommentNode = {
        let node = DynamicHotCommentNode()
        node.backgroundColor = .XiTu.hotSortBg
        return node
    }()

    /// 圈子, 可能没有, 高度 28
    private lazy var circleTagNode: ASButtonNode = {
        let node = ASButtonNode()
        node.contentSpacing = 4
        node.backgroundColor = .XiTu.circleTagBG
        node.setImage(UIImage(named: "icon_circle"), for: .normal)
        node.imageNode.contentMode = .scaleAspectFit
        node.contentEdgeInsets = .init(top: 4, left: 5, bottom: 4, right: 8)
        node.cornerRadius = round(12)
        return node
    }()

    private lazy var diggInfoNode: DynamicDigUsersCardNode = {
        let node = DynamicDigUsersCardNode()
        return node
    }()

    /// 分享
    private lazy var shareNode: ASButtonNode = {
        let node = ASButtonNode()
        node.setImage(UIImage(named: "icon_share"), for: .normal)
        node.setTitle("分享", with: .systemFont(ofSize: 12, weight: .regular), with: .XiTu.commentCount, for: .normal)
        node.contentHorizontalAlignment = .left
        node.contentSpacing = 5
        return node
    }()

    /// 评论数
    private lazy var commentNode: ASButtonNode = {
        let node = ASButtonNode()
        node.setImage(UIImage(named: "icon_comment_dynamic"), for: .normal)
        node.contentSpacing = 5
        return node
    }()

    /// 点赞数
    private lazy var likeNode: ASButtonNode = {
        let node = ASButtonNode()
        node.setImage(UIImage(named: "icon_undig"), for: .normal)
        node.setImage(UIImage(named: "icon_dig_blue"), for: .selected)
        node.contentHorizontalAlignment = .right
        node.contentSpacing = 5
        return node
    }()
}

// MARK: - 布局
extension DynamicListCellNode {

    // FIXED: - layout 既能获得最终将要展示的布局信息 (类比于: layoutSubViews)
    // override func layoutDidFinish() {
    override func layout() {
        super.layout()

        if showOrHiddenNode.isHidden == true { return }

        // 不显示更多按钮
        if shortContentNode.lineCount <= 3 && shortContentNode.maximumNumberOfLines == 4/* > 3*/ {
            showOrHiddenNode.isHidden = true
            setNeedsLayout()
            return
        }

        // FIXED: - 不会出现! (注: UILabel 会出现此种情况 -- 计算属性字符串后的高度会高于 label 的实际高度)
        /*
         // 等于3行, 按钮显示为 **收起*, 此时判定为 ASTextNode 截断问题, 对 maxline 设置为 4 并隐藏按钮
        if shortContentNode.lineCount == 3, showOrHiddenNode.isSelected {
            shortContentNode.maximumNumberOfLines = 4
            showOrHiddenNode.isHidden = true
            setNeedsLayout()
            return
        }
         */

        // 行数大于 3 行, 按钮显示为 **展开**, 设置最大行高
        if shortContentNode.lineCount > 3, !showOrHiddenNode.isSelected {
            shortContentNode.maximumNumberOfLines = 3
            setNeedsLayout()
            return
        }
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var vChildren: [ASLayoutElement] = []

        // 头部信息
        do {
            avatarNode.style.preferredSize = CGSize(width: 40, height: 40)
            avatarNode.style.spacingAfter = 8

            nicknameNode.style.height = ASDimensionMake(24)
            positionNode.style.height = ASDimensionMake(16)
            let vStack = ASStackLayoutSpec.vertical()
            vStack.justifyContent = .start
            vStack.alignItems = .start
            vStack.children = [nicknameNode, positionNode]

            let hStack = ASStackLayoutSpec.horizontal()
            hStack.justifyContent = .start
            hStack.children = [avatarNode, vStack]

            vChildren.append(hStack)
        }

        // 设置压缩进行换行
        shortContentNode.style.flexShrink = 1.0
        vChildren.append(shortContentNode)

        if !showOrHiddenNode.isHidden {
            showOrHiddenNode.style.preferredSize = CGSize(width: 100, height: 20)
            vChildren.append(showOrHiddenNode)
        }

        let imagesCount = dataSource.imageCount
        if imagesCount != 0 {
            let rowCount = ceil(CGFloat(imagesCount) / 3)
            let spacHeihgt = (rowCount - 1) * floor(5.sizeFromIphone6)
            let imageHeigt = rowCount * floor(111.sizeFromIphone6)
            imgCollectionNode.style.height = ASDimensionMake(imageHeigt + spacHeihgt)
            vChildren.append(imgCollectionNode)
        }

        if !hotShortNode.isHidden {
            vChildren.append(hotShortNode)
        }

        do {
            var hChildren: [ASLayoutElement] = []

            if !circleTagNode.isHidden {
                circleTagNode.style.height = ASDimensionMake(24)
                hChildren.append(circleTagNode)
            }

            let spec = ASLayoutSpec()
            spec.style.flexGrow = 1.0
            hChildren.append(spec)

            if !diggInfoNode.isHidden {
                diggInfoNode.style.height = ASDimensionMake(23)
                hChildren.append(diggInfoNode)
            }

            if hChildren.count > 1 {
                let hStack = ASStackLayoutSpec.horizontal()
                hStack.alignItems = .center
                hStack.children = hChildren

                vChildren.append(hStack)
            }
        }

        // 分享, 评论, 点赞
        do {
            shareNode.style.flexGrow = 1.0
            commentNode.style.flexGrow = 1.0
            let hStack = ASStackLayoutSpec.horizontal()
            hStack.justifyContent = .center
            likeNode.style.flexGrow = 1.0
            hStack.children = [shareNode, commentNode, likeNode]
            hStack.style.height = ASDimensionMake(34)
            let inset = ASInsetLayoutSpec(insets: .zero, child: hStack)

            vChildren.append(inset)
        }

        let vStack = ASStackLayoutSpec.vertical()
        // 子控件填充整个 cross 轴.(对 vStack 来说,使子控件 水平 方向填充整个宽度)
        vStack.alignItems = .stretch
        vStack.spacing = 8
        vStack.children = vChildren

        let horInsetValue: CGFloat = 16
        let innerInset = ASInsetLayoutSpec(insets: .init(top: horInsetValue, left: horInsetValue, bottom: 8, right: horInsetValue), child: vStack)

        let bgSpec = ASBackgroundLayoutSpec(child: innerInset, background: bgContentNode)

        let outInset = ASInsetLayoutSpec(insets: .only(.bottom, value: 8), child: bgSpec)

        return outInset
    }
}

// MARK: - binding viewModel && event handler

extension DynamicListCellNode {

    func eventListen() {
        // FIXED: - 方法监听中尽量舍弃 rx
        //showOrHiddenNode.rx.tap.asDriver().throttle(.seconds(1), latest: false).drive(onNext: { _ in }).disposed(by: disposeBag)
        showOrHiddenNode.addTarget(self, action: #selector(self.showOrHiddenButtonClicked(_:)), forControlEvents: .touchUpInside)

        likeNode.addTarget(self, action: #selector(self.likeButtonClicked(_:)), forControlEvents: .touchUpInside)

        diggInfoNode.addTarget(self, action: #selector(self.showDiggView), forControlEvents: .touchUpInside)
    }

    func bindViewModel() {

        viewModel.output.avatarUrl.subscribe(onNext: { [weak self] url in
            if  let url = url, let imgNode = self?.avatarNode {
                imgNode.kf.setImage(with: url, placeholder: nil, options: Array.jjListAvatarOptions(with: 40))
            } else {
                self?.avatarNode.backgroundColor = .randomWithoutAlpha
            }
        }).disposed(by: disposeBag)

        viewModel.output.nickname.subscribe(onNext: { [weak self] attrString in
            self?.nicknameNode.attributedText = attrString
        }).disposed(by: disposeBag)

        viewModel.output.position.subscribe(onNext: { [weak self] attrString in
            self?.positionNode.attributedText = attrString
        }).disposed(by: disposeBag)

        viewModel.output.recommendContent.subscribe(onNext: { [weak self] attrString in
            self?.shortContentNode.attributedText = attrString
        }).disposed(by: disposeBag)

        viewModel.output.imageList.subscribe(onNext: { [weak self] list in
            self?.imgCollectionNode.reloadData()
        }).disposed(by: disposeBag)

        viewModel.output.hiddenImageList.subscribe(onNext: { [weak self] _ in
            self?.imgCollectionNode.isHidden = true
            self?.setNeedsLayout()
        }).disposed(by: disposeBag)

        viewModel.output.hotComment.subscribe(onNext: { [weak self] hotModel in
            self?.hotShortNode.configure(with: hotModel)
        }).disposed(by: disposeBag)

        viewModel.output.hiddenHotComment.subscribe(onNext: { [weak self] _ in
            self?.hotShortNode.isHidden = true
            self?.setNeedsLayout()
        }).disposed(by: disposeBag)

        viewModel.output.topicTitle.subscribe(onNext: { [weak self] title in
            self?.circleTagNode.setTitle(title, with: .systemFont(ofSize: 12, weight: .regular), with: .XiTu.circleTagTitle, for: .normal)
        }).disposed(by: disposeBag)

        viewModel.output.hiddenTopic.subscribe(onNext: { [weak self] _ in
            self?.circleTagNode.isHidden = true
            self?.setNeedsLayout()
        }).disposed(by: disposeBag)

        viewModel.output.commentCount.subscribe(onNext: { [weak self] title in
            self?.commentNode.setTitle(title, with: .systemFont(ofSize: 12, weight: .regular), with: .XiTu.commentCount, for: .normal)
        }).disposed(by: disposeBag)

        viewModel.output.digUsers.subscribe(onNext: { [weak self] users in
            self?.diggInfoNode.isHidden = false
            self?.diggInfoNode.configure(with: users)
            self?.setNeedsLayout()
        }).disposed(by: disposeBag)

        viewModel.output.hiddenDigUsers.subscribe(onNext: { [weak self] _ in
            self?.diggInfoNode.isHidden = true
            self?.setNeedsLayout()
        }).disposed(by: disposeBag)

        viewModel.output.likeButton.subscribe(onNext: { [weak self] tuple in
            self?.likeNode.setTitle(tuple.0, with: .systemFont(ofSize: 12, weight: .regular), with: .XiTu.commentCount, for: .normal)
            self?.likeNode.setImage(tuple.1, for: .normal)
            self?.likeNode.setImage(tuple.2, for: .selected)
        }).disposed(by: disposeBag)

        viewModel.output.changeLikeStatus.subscribe(onNext: { [weak self] isSelected in
            self?.likeNode.isSelected = isSelected
        }).disposed(by: disposeBag)

        viewModel.output.digged.subscribe(onNext: { [weak self] user in
            self?.dataSource.diggRecomment(with: user)
            self?.viewModel.input.reloadDiggUesrs(self?.dataSource.diggUser ?? [])
            self?.viewModel.input.reloadLikeCount(self?.dataSource.diggCount ?? 0)
        }).disposed(by: disposeBag)

        viewModel.output.unDigged.subscribe(onNext: { [weak self] user in
            self?.dataSource.unDiggRecomment()
            self?.viewModel.input.reloadDiggUesrs(self?.dataSource.diggUser ?? [])
            self?.viewModel.input.reloadLikeCount(self?.dataSource.diggCount ?? 0)
        }).disposed(by: disposeBag)

        viewModel.output.reloadDiggCount.subscribe(onNext: { [weak self] count in
            self?.likeNode.setTitle(count, with: .systemFont(ofSize: 12, weight: .regular), with: .XiTu.commentCount, for: .normal)
        }).disposed(by: disposeBag)
    }
}

fileprivate extension DynamicListCellNode {

    @objc func showOrHiddenButtonClicked(_ button: ASButtonNode) {
        button.isSelected.toggle()
        shortContentNode.maximumNumberOfLines = button.isSelected ? 0 : 3
        setNeedsLayout()
    }

    @objc func likeButtonClicked(_ button: ASButtonNode) {
        viewModel.input.likeButtonAction(isLike: button.isSelected)
    }

    @objc func showDiggView() {
        self.delegate?.listCellNode(self, showDiggForMsg: dataSource.recommendId)
    }
}

extension DynamicListCellNode {

    func configure(with model: DynamicListModel) {
        dataSource.configure(with: model)
        viewModel.input.configure(with: model)
    }

    fileprivate func initizalizeUI() {
        backgroundColor = .XiTu.cellBg
        automaticallyManagesSubnodes = false

        addSubnode(bgContentNode)
        addSubnode(avatarNode)
        addSubnode(nicknameNode)
        addSubnode(positionNode)
        addSubnode(shortContentNode)
        addSubnode(showOrHiddenNode)
        addSubnode(imgCollectionNode)
        addSubnode(hotShortNode)
        addSubnode(circleTagNode)
        addSubnode(diggInfoNode)
        addSubnode(shareNode)
        addSubnode(commentNode)
        addSubnode(likeNode)
    }
}

// MARK: - ASCollectionDelegate

extension DynamicListCellNode: ASCollectionDelegate {

    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        // @note: - 这里如果有额外的数据操作就该调用 viewModel.input.xxx 并在 viewModel.output.xxx.subscribe(xx 中展示结果
        delegate?.listCellNode(self, selectedView: collectionNode.view, selectedImage: indexPath.row, allImages: dataSource.allImages)
    }

}
