//
/*
* ****************************************************************
*
* 文件名称 : UIViewController+DrIndex
* 作   者 : Created by 坤
* 创建时间 : 2022/3/14 11:29 AM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/14 初始版本
*
* ****************************************************************
*/

import UIKit

fileprivate extension UIViewController {

    struct AssociateKeys {
        static var isInteractionKey: Void?
        //static var hideNavBarKey: Void?
        static var indexKey: Void?
    }
}

extension UIViewController {

// MARK: - 添加的属性

    var dr_isInteraction: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.isInteractionKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociateKeys.isInteractionKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    var dr_index: Int {
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.indexKey) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociateKeys.indexKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

//    var dr_hideNavBar: Bool {
//        get {
//            return objc_getAssociatedObject(self, &AssociateKeys.hideNavBarKey) as? Bool ?? false
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociateKeys.hideNavBarKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
//        }
//    }
}
