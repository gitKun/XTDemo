//
/*
* ****************************************************************
*
* 文件名称 : ViewController
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 4:29 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import UIKit
import Moya

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 15.0, *) {
            self.view.keyboardLayoutGuide.followsUndockedKeyboard = true
        } else {
            // Fallback on earlier versions
        }
    }
}

