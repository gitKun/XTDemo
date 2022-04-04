//
/*
* ****************************************************************
*
* 文件名称 : DynamicTopicCollectionNode
* 作   者 : Created by 坤
* 创建时间 : 2022/4/4 15:54
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/4 初始版本
*
* ****************************************************************
*/

import Foundation
import Foundation
import UIKit
import AsyncDisplayKit
import Kingfisher

final class DynamicTopicCollectionNode: ASCellNode {

// MARK: - 生命周期

    override init() {
        super.init()

        self.automaticallyManagesSubnodes = false
        self.addSubnode(self.iconNode)
        self.addSubnode(self.titleNode)
        self.addSubnode(self.countBgNode)
        self.addSubnode(self.countNode)
    }

    // 已经进入展示状态, 进行 开始/创建动画, image展示, 等
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
    }

    // 已经结束展示, 进行 暂停/移除 动画, image 的内存回收, 等
    override func didExitDisplayState() {
        super.didExitDisplayState()
    }

// MARK: - 布局

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        var vChildren: [ASLayoutElement] = []

        iconNode.style.preferredSize = CGSize(width: 60, height: 60)
        let iconInset = ASInsetLayoutSpec(insets: .init(top: 5, left: 0, bottom: 0, right: 5), child: iconNode)

        if !countNode.isHidden, !countBgNode.isHidden {
            let countInset = ASInsetLayoutSpec(insets: .init(top: 3, left: 5, bottom: 3, right: 5), child: countNode)
            let countBgSpec = ASBackgroundLayoutSpec(child: countInset, background: countBgNode)
            let countBgInset = ASInsetLayoutSpec(insets: .init(top: 0, left: .infinity, bottom: .infinity, right: 0), child: countBgSpec)
            let iconAndCountOverlay = ASOverlayLayoutSpec(child: iconInset, overlay: countBgInset)

            vChildren.append(iconAndCountOverlay)
        } else {
            vChildren.append(iconInset)
        }

        vChildren.append(titleNode)

        let vStack = ASStackLayoutSpec.vertical()
        vStack.spacing = 8
        vStack.alignItems = .center
        vStack.children = vChildren

        let inset = ASInsetLayoutSpec(insets: .init(top: 0, left: 0, bottom: 0, right: 3), child: vStack)

        return inset
    }

// MARK: - UI element

    private lazy var iconNode: ASImageNode = {
        let node = ASImageNode()
        node.cornerRadius = 4
        node.backgroundColor = .XiTu.cellBg
        return node
    }()

    private lazy var titleNode: ASTextNode = {
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        return node
    }()

    private lazy var countBgNode: ASDisplayNode = {
        let node = ASDisplayNode { () -> UIView in
            let corner = DrCornerView(frame: .zero)
            corner.cornerLocation = .init(topLeft: .auto, topRight: .auto, bottomRight: .auto, bottomLeft: .null)
            corner.useMaskCorner = true
            corner.backgroundColor = .XiTu.unreadBg
            return corner
        }
        return node
    }()

    private let countNode = ASTextNode()
}

extension DynamicTopicCollectionNode {

    func configure(with model: TopicModel) {

        var count: String? = nil
        if model.newShortMsgCount > 0 {
            count = model.newShortMsgCount > 99 ? "99+" : "\(model.newShortMsgCount)"
        }

        if let count = count {
            let font = UIFont.systemFont(ofSize: 9, weight: .regular)
            let attr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: font]
            countNode.attributedText = NSAttributedString(string: count, attributes: attr)
        } else {
            countNode.isHidden = true
            countBgNode.isHidden = true
        }

        if let iconUrl = model.topicInfo?.icon, let url = URL(string: iconUrl) {
            iconNode.kf.setImage(with: url)
        } else {
            iconNode.backgroundColor = .randomWithoutAlpha
        }

        if let title = model.topicInfo?.title {
            let font = UIFont.systemFont(ofSize: 11, weight: .regular)
            let attr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.XiTu.circleTagTitle, .font: font]
            titleNode.attributedText = .init(string: title, attributes: attr)
        }
    }
}
