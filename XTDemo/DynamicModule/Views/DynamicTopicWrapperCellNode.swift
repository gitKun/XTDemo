//
/*
* ****************************************************************
*
* 文件名称 : DynimicTopicListCellNode
* 作   者 : Created by 坤
* 创建时间 : 2022/3/26 12:34 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/26 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import AsyncDisplayKit

final class DynamicTopicWrapperCellNode: ASCellNode {

// MARK: - 属性

    var topicArray: [TopicModel] = []

// MARK: - 生命周期

    override init() {
        super.init()

        backgroundColor = .XiTu.cellBg

        self.automaticallyManagesSubnodes = false
        self.addSubnode(self.bgContentNode)
        self.addSubnode(self.titleNode)
        self.addSubnode(self.subTitleNode)
        self.addSubnode(self.collectionNode)
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
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.justifyContent = .spaceBetween
        hStack.children = [titleNode, subTitleNode]

        collectionNode.style.height = ASDimensionMake(88)

        let vStack = ASStackLayoutSpec.vertical()
        vStack.spacing = 8
        vStack.children = [hStack, collectionNode]

        let innerInset = ASInsetLayoutSpec(insets: .init(top: 10, left: 16, bottom: 8, right: 16), child: vStack)
        let bgSpec = ASBackgroundLayoutSpec(child: innerInset, background: bgContentNode)

        let outInset = ASInsetLayoutSpec(insets: .only(.bottom, value: 8), child: bgSpec)

        return outInset
    }

// MARK: - UI element

    private lazy var bgContentNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.backgroundColor = .XiTu.cellContenBg
        node.isLayerBacked = true
        return node
    }()

    private lazy var titleNode: ASTextNode = {
        let node = ASTextNode()
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let attr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.XiTu.nickName, .font: font]
        node.attributedText = .init(string: "推荐圈子", attributes: attr)
        return node
    }()

    private lazy var subTitleNode: ASButtonNode = {
        let node = ASButtonNode()
        node.setTitle("我加入的圈子", with: UIFont.systemFont(ofSize: 12, weight: .regular), with: UIColor.XiTu.position, for: .normal)
        return node
    }()

    private lazy var collectionNode: ASCollectionNode = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 68, height: 88)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let node = ASCollectionNode.init(collectionViewLayout: layout)
        node.delegate = self
        node.dataSource = self
        node.alwaysBounceVertical = false
        node.alwaysBounceHorizontal = false
        node.showsHorizontalScrollIndicator = false
        return node
    }()
}

extension DynamicTopicWrapperCellNode {

    func configure(with list: [TopicModel]) {
        topicArray = list
        collectionNode.reloadData()
    }
}

extension DynamicTopicWrapperCellNode: ASCollectionDelegate, ASCollectionDataSource {

    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        topicArray.count// == 0 ? 0 : 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let model = topicArray[indexPath.row]
        let cellNode = DynamicTopicCollectionNode()
        cellNode.configure(with: model)
        return cellNode
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let model = topicArray[indexPath.row]
        // TODO: - delegate
        print(model.topicInfo?.topicId ?? "获取 topic id 失败!")
    }
}
