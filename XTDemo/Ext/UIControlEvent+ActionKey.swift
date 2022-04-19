//
/*
* ****************************************************************
*
* 文件名称 : UIControlEvent+ActionKey
* 作   者 : Created by 坤
* 创建时间 : 2022/4/19 11:43
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/19 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit


@available(iOS 13.0, *)
fileprivate struct AssociatedActionKeys {
    static var kDefaultKey: Void?

    static var touchDown: Void?
    static var touchDownRepeat: Void?
    static var touchDragInside: Void?
    static var touchDragOutside: Void?
    static var touchDragEnter: Void?
    static var touchDragExit: Void?
    static var touchUpInside: Void?
    static var touchUpOutside: Void?
    static var touchCancel: Void?
    static var valueChanged: Void?
    static var primaryActionTriggered: Void?

    @available(iOS 14.0, *)
    static var menuActionTriggered: Void?

    static var editingDidBegin: Void?
    static var editingChanged: Void?
    static var editingDidEnd: Void?
    static var editingDidEndOnExit: Void?
    static var allTouchEvents: Void?
    static var allEditingEvents: Void?
    static var applicationReserved: Void?
    static var systemReserved: Void?
    static var allEvents: Void?
}

@available(iOS 13.0, *)
extension UIControl.Event {

    var publisherActionKey: UnsafeRawPointer {

        if #available(iOS 14.0, *) {
            if case .menuActionTriggered = self {
                return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.valueChanged))
            }
        }

        switch self {
        case .touchDown:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.touchDown))
        case .touchDownRepeat:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.touchDownRepeat))
        case .touchDragInside:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.touchDragInside))
        case .touchDragOutside:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.touchDragOutside))
        case .touchDragEnter:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.touchDragEnter))
        case .touchDragExit:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.touchDragExit))
        case .touchUpInside:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.touchUpInside))
        case .touchUpOutside:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.touchUpOutside))
        case .touchCancel:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.touchCancel))
        case .valueChanged:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.valueChanged))
        case .primaryActionTriggered:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.primaryActionTriggered))
        case .editingDidBegin:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.editingDidBegin))
        case .editingChanged:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.editingChanged))
        case .editingDidEnd:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.editingDidEnd))
        case .editingDidEndOnExit:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.editingDidEndOnExit))
        case .allTouchEvents:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.allTouchEvents))
        case .allEditingEvents:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.allEditingEvents))
        case .applicationReserved:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.applicationReserved))
        case .systemReserved:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.systemReserved))
        case .allEvents:
            return .init(UnsafeMutableRawPointer(&AssociatedActionKeys.allEvents))
        default:
            return UnsafeRawPointer(UnsafeMutableRawPointer(&AssociatedActionKeys.kDefaultKey))
        }
    }
}
