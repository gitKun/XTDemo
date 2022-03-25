//
/*
* ****************************************************************
*
* 文件名称 : XTOnlyImageCollectionNode
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:31 PM
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
import Kingfisher

final class XTOnlyImageCollectionNode: ASCellNode {

// MARK: - 生命周期

    override init() {
        super.init()

        self.imageNode.contentMode = .scaleAspectFill
        self.imageNode.clipsToBounds = true
        self.imageNode.backgroundColor = .XiTu.cellBg
        self.addSubnode(imageNode)
    }

    // 已经进入展示状态, 进行 开始/创建动画, image展示, 等
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
    }

    // 已经结束展示, 进行 暂停/移除 动画, image 的内存回收, 等
    override func didExitDisplayState() {
        super.didExitDisplayState()
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: imageNode)
    }

// MARK: - UI element

    private let imageNode = ASImageNode()
}

extension XTOnlyImageCollectionNode {

    func configure(with remotePath: String?) {
        if let remotePath = remotePath, let url = URL(string: remotePath) {
            imageNode.kf.setImage(with: url, placeholder: nil, failureImage: nil)
        } else {
            // TODO: - 设置失败的图片
            imageNode.backgroundColor = .randomWithoutAlpha
        }
    }
}
