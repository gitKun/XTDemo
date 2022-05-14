//
/*
* ****************************************************************
*
* 文件名称 : DynamicListCell
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
import Combine


/// cell subview 事件处理
protocol DynamicListCellDelegate: AnyObject {

    func listCell(_ cell: DynamicListCell, selectedView: UIView, selectedImage at: Int, allImages: [String])

    func listCell(_ cell: DynamicListCell, showDiggForMsg: String?)

    // TODO: - 需要点击头像, 分享 的时间传递
}



final class DynamicListCell: UITableViewCell {

// MARK: - 属性

    internal weak var delegate: DynamicListCellDelegate?

    private let viewModel: DynamicListCellModelType = DynamicListCellModel()
    private var cancellable: Set<AnyCancellable> = []

    private let dataSource = DynamicListCellDataSource()

// MARK: - 生命周期


// MARK: - UI element

}

// MARK: - event handler

extension DynamicListCell {

    func eventListen() {
    }
}

// MARK: - binding viewModel

extension DynamicListCell {

    func bindViewModel() {
    }
}
