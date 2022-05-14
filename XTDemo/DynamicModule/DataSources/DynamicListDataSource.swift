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
import UIKit


/// 为沸点列表 UITableView 提供数据, 遵守 UITableViewDataSource 协议
final class DynamicListDataSource: NSObject, UITableViewDataSource {

    private var commendList: [DynamicDisplayType] = []
    private var wrappedModel: DynamicDisplayModel? = nil

// MARK: - 数据操作

    var nextCursor: String {
        return wrappedModel?.cursor ?? "0"
    }

    var needHotDynamic: Bool {
        return (10..<30).contains(commendList.count)
    }

    func newData(from wrapped: DynamicDisplayModel) {
        wrappedModel = wrapped
        commendList.removeAll()
        commendList.append(contentsOf: wrapped.displayModels)
    }

    // func moreData(from wrapped: XTListResultModel, callback: ([IndexPath]) -> Void) {
    func moreData(from wrapped: DynamicDisplayModel) -> [IndexPath] {
        // FIXED: - 进行数据完整性验证!
        guard let cursor = wrappedModel?.cursorInfoSting else { return [] }
        guard cursor == wrapped.cursor else { return [] }

        wrappedModel = wrapped
        let list = wrapped.displayModels

        guard !list.isEmpty else { return [] }

        let startRow = commendList.count
        let endRow = startRow + list.count
        let insetIndexPathArray: [IndexPath] = (startRow..<endRow).map {
            return IndexPath(row: $0, section: 0)
        }
        commendList.append(contentsOf: list)
        return insetIndexPathArray
    }

// MARK: - ASTableDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        commendList.count// == 0 ? 0 : 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let model = commendList[indexPath.row]

        switch model {
        case .dynamic(let dynModel):
            print("\(dynModel.msgId ?? "")")
        case .topicList(let topic):
            print("\(topic.count)")
        case .hotList(let list):
            print("\(list.count)")
        }

        return UITableViewCell.init(style: .default, reuseIdentifier: "")
    }
}

