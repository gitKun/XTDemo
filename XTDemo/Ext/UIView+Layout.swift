//
//  UIView+Layout.swift
//  DR_SwiftTap
//
//  Created by DR_Kun on 2021/2/25.
//

import Foundation
import UIKit


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
        guard let baseWidth = DrLayoutInfo.windowWidth else { fatalError("请调用 UIWindow 的 setupLayoutFitInfo!") }
        return baseWidth / DrLayoutInfo.targetBaseWidth * self
    }
}

extension Int: BaseiPhone6Size {
    public var sizeFromIphone6: CGFloat {
        guard let baseWidth = DrLayoutInfo.windowWidth else { fatalError("请调用 UIWindow 的 setupLayoutFitInfo!") }
        return baseWidth / DrLayoutInfo.targetBaseWidth * CGFloat(self)
    }
}

extension Float: BaseiPhone6Size {
    public var sizeFromIphone6: CGFloat {
        guard let baseWidth = DrLayoutInfo.windowWidth else { fatalError("请调用 UIWindow 的 setupLayoutFitInfo!") }
        return baseWidth / DrLayoutInfo.targetBaseWidth * CGFloat(self)
    }
}

extension Double: BaseiPhone6Size {
    public var sizeFromIphone6: CGFloat {
        guard let baseWidth = DrLayoutInfo.windowWidth else { fatalError("请调用 UIWindow 的 setupLayoutFitInfo!") }
        return baseWidth / DrLayoutInfo.targetBaseWidth * CGFloat(self)
    }
}


public enum DrLayoutInfo {

    fileprivate static var windowWidth: CGFloat?
    fileprivate static let targetBaseWidth: CGFloat = 375.0

    /// isFullScreen 是否是全面屏(刘海屏 iPhone X, XR, 11, 11 pro, ...)
    public static fileprivate(set) var isFullScreen: Bool = true

    public static fileprivate(set) var screenScale: CGFloat = 2.0

    /// 顶部导航的高度
    public static var navigationBarHeight: CGFloat {
        // 'statusBarFrame' was deprecated in iOS 13.0: Use the statusBarManager property of the window scene instead.
        // return UIApplication.shared.statusBarFrame.height == 44 ? 88 : 64
        return  isFullScreen ? 88 : 64
    }

    /// 顶部安全区域的高度
    /// @note: 仅针对竖屏模式
    public static var topSafeHeight: CGFloat {
        return  isFullScreen ? 44 : 0
    }

    /// 底部的安全区域
    /// @note: 仅针对竖屏模式
    public static var bottomSafeHeight: CGFloat {
        // 对于仅仅有竖屏的App 直接判断 statusBarFrame.height 就行
        // return UIApplication.shared.statusBarFrame.height == 44 ? 34 : 0
        return isFullScreen ? 34 : 0
    }
}


extension UIWindow {

    /// 缓存屏幕宽度,不需要重复调用(iOS13 后,大屏幕,横屏,分屏状态也不再需要额外调用)
    /// @note: iOS13 之前请在 AppDelegate 的 application(:, didFinishLaunchingWithOptions:) 中调用
    /// @note: iOS13 之后请确保在 SceneDelegate 的 scene(:, willConnectTo:, options:) 中调用
    public static func setupLayoutFitInfo() {
        assert(Thread.current == Thread.main, "请务必在主线程调用此函数!")
        DrLayoutInfo.screenScale = UIScreen.main.scale

        let isRotate = UIWindow.isLandscape
        let portraitWidth = isRotate ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width

        // TODO: - 考虑 iPad 版本适配
        DrLayoutInfo.windowWidth = portraitWidth > DrLayoutInfo.targetBaseWidth ? portraitWidth : DrLayoutInfo.targetBaseWidth

        if let unwrapedWindow = forwardKeyWindow(),
           unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0
        {
            DrLayoutInfo.isFullScreen = true
        } else {
            DrLayoutInfo.isFullScreen = false
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

    public static func forwardKeyWindow() -> UIWindow? {

        if #available(iOS 13, *) {
            var keyWindow: UIWindow?
            if #available(iOS 15, *) {
                keyWindow = UIApplication.shared.connectedScenes.filter {
                    $0.activationState == .foregroundActive
                }.compactMap{
                    $0 as? UIWindowScene
                }.first?.keyWindow
            } else {
                keyWindow = UIApplication.shared.connectedScenes.filter {
                    $0.activationState == .foregroundActive
                }.compactMap{
                    $0 as? UIWindowScene
                }.first?.windows.filter {
                    $0.isKeyWindow
                }.first
            }

            // FIXED: - iOS 14 出现 UIScene 的 activationState 获取为 .unattached
            if keyWindow == nil {
                #if DEBUG
                let scenes = UIApplication.shared.connectedScenes.compactMap {
                    $0 as? UIWindowScene
                }
                let windows = scenes.first?.windows
                let _ = windows?.filter { $0.isKeyWindow }.first
                #endif

                keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last
            }

            return keyWindow
        } else {
            if let window = UIApplication.shared.delegate?.window {
                return window
            }
        }
        return nil
    }
}


// MARK: - 拓展 auto layout

extension UIView {

    public func insetToSafeArea(with edge: UIEdgeInsets){
        guard let superview = superview else { fatalError("请先将 \(self) 添加到 superView") }

        var guide: UILayoutGuide
        if #available(iOS 11.0, *) {
            guide = superview.safeAreaLayoutGuide
        } else {
            guide = superview.layoutMarginsGuide
        }

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: guide.topAnchor, constant: edge.top),
            leftAnchor.constraint(equalTo: guide.leftAnchor, constant: edge.left),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -edge.bottom),
            rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -edge.right)
        ])
    }

    public func insetToSuperView(with edge: UIEdgeInsets){
        guard let superview = self.superview else { fatalError("请先将 \(self) 添加到 superView") }

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: edge.top),
            leftAnchor.constraint(equalTo: superview.leftAnchor, constant: edge.left),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -edge.bottom),
            rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -edge.right)
        ])
    }
}


extension UIView {

    public func constraints(on anchor: NSLayoutYAxisAnchor) -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }

        return superview.constraints.filtered(view: self, anchor: anchor)
    }

    public func constraints(on anchor: NSLayoutXAxisAnchor) -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }

        return superview.constraints.filtered(view: self, anchor: anchor)
    }

    public func constraints(on anchor: NSLayoutDimension) -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }

        return constraints.filtered(view: self, anchor: anchor) + superview.constraints.filtered(view: self, anchor: anchor)
    }

}

fileprivate extension NSLayoutConstraint {

    func matches(view: UIView, anchor: NSLayoutYAxisAnchor) -> Bool {
        if let firstView = firstItem as? UIView, firstView == view && firstAnchor == anchor {
            return true
        }

        if let secondView = secondItem as? UIView, secondView == view && secondAnchor == anchor {
            return true
        }

        return false
    }

    func matches(view: UIView, anchor: NSLayoutXAxisAnchor) -> Bool {
        if let firstView = firstItem as? UIView, firstView == view && firstAnchor == anchor {
            return true
        }

        if let secondView = secondItem as? UIView, secondView == view && secondAnchor == anchor {
            return true
        }

        return false
    }

    func matches(view: UIView, anchor: NSLayoutDimension) -> Bool {
        if let firstView = firstItem as? UIView, firstView == view && firstAnchor == anchor {
            return true
        }

        if let secondView = secondItem as? UIView, secondView == view && secondAnchor == anchor {
            return true
        }

        return false
    }
}

fileprivate extension Array where Element == NSLayoutConstraint {

    func filtered(view: UIView, anchor: NSLayoutYAxisAnchor) -> [NSLayoutConstraint] {
        return filter { constraint in
            constraint.matches(view: view, anchor: anchor)
        }
    }

    func filtered(view: UIView, anchor: NSLayoutXAxisAnchor) -> [NSLayoutConstraint] {
        return filter { constraint in
            constraint.matches(view: view, anchor: anchor)
        }
    }

    func filtered(view: UIView, anchor: NSLayoutDimension) -> [NSLayoutConstraint] {
        return filter { constraint in
            constraint.matches(view: view, anchor: anchor)
        }
    }
}



// MARK: - 废弃的方法

/*
public struct IsFullScreen {

    fileprivate static var isIphoneX: Bool?

    public static var isFullScreen: Bool {

        if let result = isIphoneX {
            return result
        }

        if #available(iOS 11, *) {

            let keyWindow = IsFullScreen.getKeyWindow()
            guard let unwrapedWindow = keyWindow  else {
                isIphoneX = false
                return false
            }

            if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                print(unwrapedWindow.safeAreaInsets)
                isIphoneX = true
                return true
            }
        }

        isIphoneX = false
        return false
    }


}

// MARK: - 对外暴露的方法

public extension IsFullScreen {

    static func getKeyWindow() -> UIWindow? {

        if #available(iOS 13, *) {
            var keyWindow: UIWindow?
            if #available(iOS 15, *) {
                keyWindow = UIApplication.shared.connectedScenes.filter {
                    $0.activationState == .foregroundActive
                }.compactMap{
                    $0 as? UIWindowScene
                }.first?.keyWindow
            } else {
                keyWindow = UIApplication.shared.connectedScenes.filter {
                    $0.activationState == .foregroundActive
                }.compactMap{
                    $0 as? UIWindowScene
                }.first?.windows.filter {
                    $0.isKeyWindow
                }.first
            }

            // FIXED: - iOS 14 出现 UIScene 的 activationState 获取为 .unattached
            if keyWindow == nil {
                #if DEBUG
                let scenes = UIApplication.shared.connectedScenes.compactMap {
                    $0 as? UIWindowScene
                }
                let windows = scenes.first?.windows
                let _ = windows?.filter { $0.isKeyWindow }.first
                #endif

                keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last
            }

            return keyWindow
        } else {
            if let window = UIApplication.shared.delegate?.window {
                return window
            }
        }
        return nil
    }
}
 */
