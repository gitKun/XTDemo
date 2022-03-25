//
/*
* ****************************************************************
*
* 文件名称 : LayoutFit
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:17 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import UIKit


private var kWindowWidth: CGFloat?
private let kTargetBaseWidth: CGFloat = 375.0


public protocol BaseiPhone6Size {
    // associatedtype Element: Numeric

    /// 以 375 为基数计算的实际的大小
    var sizeFromIphone6: CGFloat { get }

    /// 四舍五入的结果
    var roundSizeFromIphone6: CGFloat { get }

    /// 舍弃小数部分的结果
    var floorSizeFromIphone6: CGFloat { get }

    /// 向上取整的结果
    var ceilSizeFromIphone6: CGFloat { get }
}

public extension BaseiPhone6Size {

    var roundSizeFromIphone6: CGFloat { round(sizeFromIphone6) }

    var floorSizeFromIphone6: CGFloat { floor(sizeFromIphone6) }

    var ceilSizeFromIphone6: CGFloat { ceil(sizeFromIphone6) }
}

extension CGFloat: BaseiPhone6Size {
    public var sizeFromIphone6: CGFloat {
        guard let baseWidth = kWindowWidth else { fatalError("请调用 UIWindow 的 setupLayoutFitInfo!") }
        return baseWidth / kTargetBaseWidth * self
    }
}

extension Int: BaseiPhone6Size {
    public var sizeFromIphone6: CGFloat {
        guard let baseWidth = kWindowWidth else { fatalError("请调用 UIWindow 的 setupLayoutFitInfo!") }
        return baseWidth / kTargetBaseWidth * CGFloat(self)
    }
}

extension Float: BaseiPhone6Size {
    public var sizeFromIphone6: CGFloat {
        guard let baseWidth = kWindowWidth else { fatalError("请调用 UIWindow 的 setupLayoutFitInfo!") }
        return baseWidth / kTargetBaseWidth * CGFloat(self)
    }
}

extension Double: BaseiPhone6Size {
    public var sizeFromIphone6: CGFloat {
        guard let baseWidth = kWindowWidth else { fatalError("请调用 UIWindow 的 setupLayoutFitInfo!") }
        return baseWidth / kTargetBaseWidth * CGFloat(self)
    }
}

fileprivate var isFullScreen: Bool?
fileprivate var screenScale: CGFloat?


/// isFullScreen 是否是全面屏(刘海屏 iPhone X, XR, 11, 11 pro, ...)
public var k_dr_iSiPhoneX: Bool {

    if let result = isFullScreen {
        return result
    }

    isFullScreen = false
    return false
}

public var k_dr_screenScale: CGFloat { screenScale ?? 1.0 }

/// 顶部导航的高度
public var k_dr_NavigationBarHeight: CGFloat {
    // return UIApplication.shared.statusBarFrame.height == 44 ? 88 : 64
    return k_dr_iSiPhoneX ? 88 : 64
}

/// 顶部安全区域的高度
/// @note: 仅针对竖屏模式
public var k_dr_TopSafeHeight: CGFloat {
    return k_dr_iSiPhoneX ? 44 : 0
}

/// 底部的安全区域
/// @note: 仅针对竖屏模式
public var k_dr_BottomSafeHeight: CGFloat {
    // 对于仅仅有竖屏的App 直接判断 statusBarFrame.height 就行
    // return UIApplication.shared.statusBarFrame.height == 44 ? 34 : 0
    return k_dr_iSiPhoneX ? 34 : 0
}

extension UIWindow {

    /// 缓存屏幕宽度,不需要重复调用(iOS13 后,大屏幕,横屏,分屏状态也不再需要额外调用)
    /// @note: iOS13 之前请在 AppDelegate 的 application(:, didFinishLaunchingWithOptions:) 中调用
    /// @note: iOS13 之后请确保在 SceneDelegate 的 scene(:, willConnectTo:, options:) 中调用
    public static func setupLayoutFitInfo() {
        assert(Thread.current == Thread.main, "请务必在主线程调用此函数!")
        screenScale = UIScreen.main.scale
        let isRotate = UIWindow.isLandscape
        let portraitWidth = isRotate ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width
        // TODO: - 考虑 iPad 版本适配
        /*
         if UIDevice.current.model.contains("iPad") {
             portraitWidth = 375.0
         }
         */
        kWindowWidth = portraitWidth

        if #available(iOS 11, *) {
            if let w = UIApplication.shared.delegate?.window,
               let unwrapedWindow = w,
               unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0
            {
                print(unwrapedWindow.safeAreaInsets)
                isFullScreen = true
            }
        }
    }

    public static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}
