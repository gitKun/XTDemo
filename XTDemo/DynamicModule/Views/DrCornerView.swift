//
/*
* ****************************************************************
*
* 文件名称 : DrCornerView
* 作   者 : Created by 坤
* 创建时间 : 2022/4/4 13:30
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/4 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit


final class DrCornerView: UIView {

// MARK: - 属性

    /// 圆角的颜色
    var cornerColor: UIColor? {
        didSet {
            if oldValue != cornerColor {
                let color = cornerColor ?? .clear
                cornerLayer.fillColor = color.cgColor
            }
        }
    }

    /// 圆角的位置
    var cornerLocation: DrCornerLocation = .allAuto {
        didSet {
            setNeedsLayout()
        }
    }

    /// 是否使用 mask 方式设置圆角
    var useMaskCorner: Bool = false {
        didSet {
            if oldValue != useMaskCorner {
                self.setNeedsLayout()
            }
        }
    }

    var borderWidth: CGFloat = 0
    var borderColor: UIColor?

// MARK: - 生命周期

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // 不支持 xib
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds != .zero {
            cornerAndBorder()
        }
    }

// MARK: - UI element

    /// 圆角的 layer
    private lazy var cornerLayer: CAShapeLayer = {
        let shape = CAShapeLayer.init()
        shape.fillRule = .evenOdd
        self.layer.insertSublayer(shape, at: UInt32.max - 3)
        return shape
    }()

    /// 描边的 layer
    private lazy var borderLayer: CAShapeLayer = {
        let shape = CAShapeLayer.init()
        self.layer.insertSublayer(shape, at: UInt32.max - 1)
        return shape
    }()
}


private extension DrCornerView {

    /// 第一种方式: 使用 CAShapeLayer 进行覆盖
    func cornerAndBorder() {
        var cornerBounds = bounds

        // 因为 iOS 线的宽度是从 0 往两边均匀分配的，所以有边框时要计算实际的圆角的边框
        let offsetLineWidth = borderWidth >= 0.5 ? borderWidth : 0
        if offsetLineWidth != 0.5 {
            cornerBounds = cornerBounds.inset(by: .all(offsetLineWidth * 0.5))
        }

        let cornerPath = UIBezierPath.cornerPath(from: cornerBounds, with: cornerLocation)
        let fillPath = UIBezierPath.init(rect: bounds)
        fillPath.append(cornerPath)

        if useMaskCorner {
            let maskLayer = CAShapeLayer()
            maskLayer.path = cornerPath.cgPath
            self.layer.mask = maskLayer
        } else {
            cornerLayer.path = fillPath.cgPath
            let color = cornerColor ?? self.superview?.backgroundColor ?? UIColor.clear
            cornerLayer.fillColor = color.cgColor
        }
    }

    // 第二种方式: 根据 CornerLocation 来对哥哥角覆盖对应的 color 的 layer
}
