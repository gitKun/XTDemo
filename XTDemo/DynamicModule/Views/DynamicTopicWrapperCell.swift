//
/*
* ****************************************************************
*
* 文件名称 : DynimicTopicListCell
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


final class DynamicTopicWrapperCell: UITableViewCell {

// MARK: - 属性

    var topicArray: [TopicModel] = []

// MARK: - 生命周期 & override


    override func prepareForReuse() {
        super.prepareForReuse()

        // TODO: - 释放 资源
    }

// MARK: - UI element

}

extension DynamicTopicWrapperCell {

    func configure(with list: [TopicModel]) {
    }
}
