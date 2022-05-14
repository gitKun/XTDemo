//
/*
* ****************************************************************
*
* 文件名称 : EmojeShowView
* 作   者 : Created by 坤
* 创建时间 : 2022/3/30 2:34 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/30 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit

class EmojeShowView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let event = event {
            event.touches(for: self)
        }
        return nil
    }
}
