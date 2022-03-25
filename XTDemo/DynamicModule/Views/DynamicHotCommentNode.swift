//
/*
* ****************************************************************
*
* 文件名称 : DynamicHotCommentNode
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:34 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import AsyncDisplayKit

final class DynamicHotCommentNode: ASDisplayNode {

// MARK: - 生命周期 && override

    override init() {
        super.init()

        self.addSubnode(self.iconNode)
        self.addSubnode(self.likeCountNode)
        self.addSubnode(self.commentNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        iconNode.style.preferredSize = CGSize(width: 40, height: 16)
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.justifyContent = .spaceBetween
        hStack.children = [iconNode, likeCountNode]
        hStack.alignItems = .center

        let vStack = ASStackLayoutSpec.vertical()
        vStack.spacing = 8
        vStack.children = [hStack, commentNode]

        let insetSpec = ASInsetLayoutSpec(insets: .all(8), child: vStack)

        return insetSpec
    }

// MARK: - UI element

    private lazy var iconNode: ASImageNode = {
        let node = ASImageNode()
        node.image = UIImage(named: "hot_comment_icon")
        return node
    }()

    private lazy var likeCountNode: ASTextNode = {
        let node = ASTextNode()
        return node
    }()

    private lazy var commentNode: ASTextNode = {
        let node = ASTextNode()
        node.maximumNumberOfLines = 0
        return node
    }()
}

extension DynamicHotCommentNode {

    func configure(with model: HotComment) {

        if let count = model.commentInfo?.diggCount, count > 0 {
            likeCountNode.isHidden = false

            let attr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.XiTu.main1, .font: UIFont.systemFont(ofSize: 14, weight: .regular)]
            likeCountNode.attributedText = NSAttributedString(string: "\(count)人赞", attributes: attr)
        } else {
            likeCountNode.isHidden = true
        }

        if let content = model.commentInfo?.commentContent {

            let font = UIFont.systemFont(ofSize: 15, weight: .regular)
            let lineHeight: CGFloat = 21
            let paragraph = NSMutableParagraphStyle()
            paragraph.maximumLineHeight = lineHeight
            paragraph.minimumLineHeight = lineHeight
            paragraph.alignment = .justified
            let baselineOffset = (lineHeight  - font.lineHeight) / 4

            let attr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.XiTu.hotCommentContent, .font: font, .paragraphStyle: paragraph, .baselineOffset: baselineOffset]
    
            // FIXME: - 对于使用 UITableViewCell 的情况, 请在 model 中添加缓存, 避免重复计算!!!
            let attributedText = EmojiAttributedProvider.shared.generateEmojiAttributedString(from: content, attributed: attr, imageHeihg: font.lineHeight)
            commentNode.attributedText = attributedText
        } else {
            commentNode.attributedText = NSAttributedString(string: "", attributes: [:])
        }
    }
}
