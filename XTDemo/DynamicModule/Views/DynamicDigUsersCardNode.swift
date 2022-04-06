//
/*
* ****************************************************************
*
* 文件名称 : DynamicDigUsersCardNode
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:36 PM
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


final class DynamicDigUsersCardNode: ASControlNode {

    override init() {
        super.init()

        self.automaticallyManagesSubnodes = false
        self.addSubnode(self.imageNode1)
        self.addSubnode(self.imageNode2)
        self.addSubnode(self.imageNode3)
        self.addSubnode(self.titleNode)
    }

// MARK: - 布局

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let imageHeihgt = constrainedSize.min.height - 1
        imageNode1.style.preferredSize = CGSize(width: imageHeihgt, height: imageHeihgt)
        imageNode2.style.preferredSize = CGSize(width: imageHeihgt, height: imageHeihgt)
        imageNode3.style.preferredSize = CGSize(width: imageHeihgt, height: imageHeihgt)
        imageNode1.cornerRadius = imageHeihgt / 2
        imageNode2.cornerRadius = imageHeihgt / 2
        imageNode3.cornerRadius = imageHeihgt / 2

        let overlayWidth: CGFloat = 5
        let inset1 = ASInsetLayoutSpec(insets: .only(.right, value: 2 * (imageHeihgt - overlayWidth)), child: imageNode1)
        let inset2 = ASInsetLayoutSpec(insets: .only(.horizontal, value: imageHeihgt - overlayWidth), child: imageNode2)
        let inset3 = ASInsetLayoutSpec(insets: .only(.left, value:2 * (imageHeihgt - overlayWidth) ), child: imageNode3)
        let overlay1 = ASOverlayLayoutSpec(child: inset1, overlay: inset2)
        let overlay = ASOverlayLayoutSpec(child: overlay1, overlay: inset3)

        let hStack = ASStackLayoutSpec.horizontal()
        hStack.spacing = 5
        hStack.alignItems = .center
        hStack.children = [overlay, titleNode]

        return ASInsetLayoutSpec(insets: .only(.left, value: 7), child: hStack)
    }

// MARK: - configure

    func configure(with list: [AuthorUserInfo]) {

        let nodeList = [imageNode3, imageNode2, imageNode1]
        nodeList.forEach { $0.isHidden = true }
        let count = list.count > 3 ? 3 : list.count
        let showModels: [AuthorUserInfo] = list.suffix(count).reversed()
        for idx in (0..<count).reversed() {
            if let imgUrl = showModels[idx].avatarLarge, let url = URL(string: imgUrl) {
                let imgNode = nodeList[idx]
                imgNode.isHidden = false
                imgNode.setImage(with: .jjListAvatarImageRequest(with: url, width: 30))
            }
        }
    }

// MARK: - UI element

    private lazy var titleNode: ASTextNode = {
        let node = ASTextNode()
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.XiTu.digCount
        ]
        node.attributedText = NSAttributedString(string: "等人赞过", attributes: attr)
        return node
    }()

    private lazy var imageNode1: ASImageNode = {
        let node = ASImageNode()
        node.borderColor = UIColor.XiTu.digAvatarBorder.cgColor
        node.borderWidth = 1.0
        node.cornerRadius = 11.5
        return node
    }()

    private lazy var imageNode2: ASImageNode = {
        let node = ASImageNode()
        node.borderColor = UIColor.XiTu.digAvatarBorder.cgColor
        node.borderWidth = 1.0
        return node
    }()

    private lazy var imageNode3: ASImageNode = {
        let node = ASImageNode()
        node.borderColor = UIColor.XiTu.digAvatarBorder.cgColor
        node.borderWidth = 1.0
        node.cornerRadius = 11.5
        return node
    }()
}
