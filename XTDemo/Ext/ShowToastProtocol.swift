//
/*
* ****************************************************************
*
* 文件名称 : ShowToastProtocol
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:26 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import Toast_Swift

protocol ShowToastProtocol {
  func showToast(_ message: String)
}

extension UIViewController: ShowToastProtocol {
    func showToast(_ message: String) {
        view.hideAllToasts(includeActivity: true)
        view.makeToast(message, position: .center)
    }
}

protocol ToastableCompatible {
    associatedtype CompatibleType

    /// Toastable extensions.
    static var toast: Toastable<CompatibleType>.Type { get }

    /// Toastable extensions.
    var toast: Toastable<CompatibleType> { get set }
}

struct Toastable<Base> {

    /// Base object to extend
    let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    init(_ base: Base) {
        self.base = base
    }
}

extension ToastableCompatible {

    static var toast: Toastable<Self>.Type {
        get {
            return Toastable<Self>.self
        }
        set {
            // this enables using Toastable to "mutate" base type
        }
    }

    var toast: Toastable<Self> {
        get {
            return Toastable(self)
        }
        set {
            // this enables using Toastable to "mutate" base type
        }
    }
}

extension UIView: ToastableCompatible {}
extension UIViewController: ToastableCompatible {}

extension Toastable where Base: UIView {
    func showCenter(message: String) {
        show(message: message, position: .center)
    }

    func showBottom(message: String) {
        show(message: message, position: .bottom)
    }

    func showTop(message: String) {
        show(message: message, position: .top)
    }

    func show(message: String, position: ToastPosition) {
        base.hideAllToasts(includeActivity: true)
        base.makeToast(message, position: position)
    }
}

extension Toastable where Base: UIViewController {
    func showCenter(message: String) {
        base.view.toast.show(message: message, position: .center)
    }

    func showBottom(message: String) {
        base.view.toast.show(message: message, position: .bottom)
    }

    func showTop(message: String) {
        base.view.toast.show(message: message, position: .top)
    }
}
