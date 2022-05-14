//
/*
* ****************************************************************
*
* 文件名称 : DrRefreshNormalHeader
* 作   者 : Created by 坤
* 创建时间 : 2022/4/16 09:44
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/16 初始版本
*
* ****************************************************************
*/

import UIKit
import MJRefresh

class DrRefreshNormalHeader: MJRefreshNormalHeader {

    deinit {
        print("\(type(of: self)) deinit! ____#")
    }

}
