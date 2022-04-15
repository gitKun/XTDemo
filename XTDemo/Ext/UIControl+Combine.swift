//
/*
* ****************************************************************
*
* 文件名称 : UIControl+Combine
* 作   者 : Created by 坤
* 创建时间 : 2022/4/15 10:05
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/15 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import Combine


extension UIButton {

    func subscriber(forTitle state: UIControl.State) -> AnySubscriber<String, Never> {
        let sinkSubscriber = Subscribers.Sink<String, Never> { _ in
        } receiveValue: { [weak self] value in
            self?.setTitle(value, for: state)
        }
        return .init(sinkSubscriber)
    }

    func publisher(forAction event: UIControl.Event) {
        
    }

}
