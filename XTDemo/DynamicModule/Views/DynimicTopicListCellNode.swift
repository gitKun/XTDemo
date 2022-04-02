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
import Kingfisher

final class DynimicTopicListCellNode: ASCellNode {

// MARK: - 生命周期

    override init() {
        super.init()

        let node = ASDisplayNode()
        
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

    
}
