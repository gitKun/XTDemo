//
/*
* ****************************************************************
*
* 文件名称 : DynamicListDataSource
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:27 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import AsyncDisplayKit

/// 为沸点列表 tableNode 提供数据, 遵守 ASTableDataSource 协议

final class DynamicListDataSource: NSObject, ASTableDataSource {

    private var commendList: [DynamicListModel] = []
    private var wrappedModel: XTListResultModel? = nil

// MARK: - 数据操作

    var nextCursor: String {
        return wrappedModel?.cursor ?? "0"
    }

    func newData(from wrapped: XTListResultModel) {
        wrappedModel = wrapped
        commendList.removeAll()
        commendList.append(contentsOf: wrapped.data ?? [])
    }

    // FIXED: - NO Callback
    // func moreData(from wrapped: XTListResultModel, callback: ([IndexPath]) -> Void) {
    func moreData(from wrapped: XTListResultModel) -> [IndexPath] {
        // FIXED: - 进行数据完整性验证!
        guard let cursor = wrappedModel?.cursorInfoSting else { return [] }
        guard cursor == wrapped.cursor else { return [] }

        wrappedModel = wrapped

        guard let list = wrapped.data else { return [] }

        let startRow = commendList.count
        let endRow = startRow + list.count
        let insetIndexPathArray: [IndexPath] = (startRow..<endRow).map {
            return IndexPath(row: $0, section: 0)
        }
        commendList.append(contentsOf: list)
        return insetIndexPathArray
    }

// MARK: - ASTableDataSource

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return commendList.count// == 0 ? 0 : 1
    }

    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cellNode = DynamicListCellNode()
        cellNode.configure(with: commendList[indexPath.row])
        return cellNode
    }
}

