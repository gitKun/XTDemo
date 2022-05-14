//
/*
* ****************************************************************
*
* 文件名称 : UIView+DrCornenr
* 作   者 : Created by 坤
* 创建时间 : 2022/4/4 12:26
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/4 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit


public enum DrCornerType {
    case value(CGFloat)
    case auto
    case null

    func cornerValue() -> CGFloat {
        switch self {
        case .value(let value):
            return value
        case .auto:
            return .infinity //.greatestFiniteMagnitude
        case .null:
            return 0
        }
    }
}

public struct DrCornerLocation {

    let topLeft: DrCornerType
    let topRight: DrCornerType
    let bottomRight: DrCornerType
    let bottomLeft: DrCornerType

    static var zero: DrCornerLocation {
        return DrCornerLocation(topLeft: .null, topRight: .null, bottomRight: .null, bottomLeft: .null)
    }

    static var allAuto: DrCornerLocation {
        return DrCornerLocation(topLeft: .auto, topRight: .auto, bottomRight: .auto, bottomLeft: .auto)
    }
}

extension UIBezierPath {

    /// 获取圆角 path
    public static func cornerPath(from cornerRect: CGRect, with cornerLocation: DrCornerLocation) -> UIBezierPath {

        let width = cornerRect.width
        let height = cornerRect.height
        let originX = cornerRect.minX
        let originY = cornerRect.minY
        let maxRadius = min(width, height) * 0.5

        var topLeftRadius = cornerLocation.topLeft.cornerValue()
        var topRightRadius = cornerLocation.topRight.cornerValue()
        var bottomRightRadius = cornerLocation.bottomRight.cornerValue()
        var bottomLeftRadius = cornerLocation.bottomLeft.cornerValue()

        topLeftRadius = topLeftRadius < maxRadius ? topLeftRadius : maxRadius
        topRightRadius = topLeftRadius < maxRadius ? topRightRadius : maxRadius
        bottomRightRadius = bottomRightRadius < maxRadius ? bottomRightRadius : maxRadius
        bottomLeftRadius = bottomLeftRadius < maxRadius ? bottomLeftRadius : maxRadius

        // 声明各个点 topLeft -> A & B, topRight -> C & D, bottomRight -> E & F, bottomLeft -> G & H;
        let topLeftPoint = CGPoint(x: originX, y: originY)
        let topRightPoint = CGPoint(x: width, y: originY)
        let bottomRightPoint = CGPoint(x: width, y: height)
        let bottomLeftPoint = CGPoint(x: originX, y: height)

        /*var aPoint = topLeftPoint
        var bPoint = topLeftPoint
        var cPoint = topRightPoint
        var dPoint = topRightPoint
        var ePoint = bottomRightPoint
        var fPoint = bottomRightPoint
        var gPoint = bottomLeftPoint
        var hPoint = bottomLeftPoint*/

        var (aPoint, bPoint, cPoint, dPoint, ePoint, fPoint, gPoint, hPoint) = (topLeftPoint, topLeftPoint, topRightPoint, topRightPoint, bottomRightPoint, bottomRightPoint, bottomLeftPoint, bottomLeftPoint)

        // 声明控制点:
        // 有控制点则为圆角处理---实际是根据定点对应的两坐标点是否一致来进行控制的
        // 否则为非圆角处理
        var aControlPoint: CGPoint!
        var bControlPoint: CGPoint!
        var cControlPoint: CGPoint!
        var dControlPoint: CGPoint!
        var eControlPoint: CGPoint!
        var fControlPoint: CGPoint!
        var gControlPoint: CGPoint!
        var hControlPoint: CGPoint!

        // 定义圆角常量
        let controlPointOffsetRatio: CGFloat = 0.552

        // 更新左上角
        if topLeftRadius > 1 {
            let offset = controlPointOffsetRatio * topLeftRadius
            aPoint = CGPoint(x: aPoint.x, y: aPoint.y + topLeftRadius)
            bPoint = CGPoint(x: bPoint.x + topLeftRadius, y: bPoint.y)
            aControlPoint = CGPoint(x: aPoint.x, y: aPoint.y - offset)
            bControlPoint = CGPoint(x: bPoint.x - offset, y: bPoint.y)
        }

        // 更新右上角
        if topRightRadius > 1 {
            let offset = controlPointOffsetRatio * topRightRadius
            cPoint = CGPoint(x: cPoint.x - topRightRadius, y: cPoint.y)
            dPoint = CGPoint(x: dPoint.x, y: dPoint.y + topRightRadius)
            cControlPoint = CGPoint(x: cPoint.x + offset, y: cPoint.y)
            dControlPoint = CGPoint(x: dPoint.x, y: dPoint.y - offset)
        }

        // 更新右下角
        if bottomRightRadius > 1 {
            let offset = controlPointOffsetRatio * bottomRightRadius
            ePoint = CGPoint(x: ePoint.x, y: ePoint.y - bottomRightRadius)
            fPoint = CGPoint(x: fPoint.x - bottomRightRadius, y: fPoint.y)
            eControlPoint = CGPoint(x: ePoint.x, y: ePoint.y + offset)
            fControlPoint = CGPoint(x: fPoint.x + offset, y: fPoint.y)
        }

        // 更新左下角
        if bottomLeftRadius > 1 {
            let offset = controlPointOffsetRatio * bottomLeftRadius
            gPoint = CGPoint(x: gPoint.x + bottomLeftRadius, y: gPoint.y)
            hPoint = CGPoint(x: hPoint.x, y: hPoint.y - bottomLeftRadius)
            gControlPoint = CGPoint(x: gPoint.x - offset, y: gPoint.y)
            hControlPoint = CGPoint(x: hPoint.x, y: hPoint.y + offset)
        }

        // 画线顺序: B(OpenPath) -> C -> D -> E -> F -> G -> H -> A -> B(ClosePath)
        let cornerPath = UIBezierPath()
        cornerPath.move(to: bPoint)
        cornerPath.addLine(to: cPoint)

        // 绘制右上角的圆弧
        if cPoint != dPoint {
            cornerPath.addCurve(to: dPoint, controlPoint1: cControlPoint, controlPoint2: dControlPoint)
        }

        // 绘制右下角
        cornerPath.addLine(to: ePoint)
        if ePoint != fPoint {
            cornerPath.addCurve(to: fPoint, controlPoint1: eControlPoint, controlPoint2: fControlPoint)
        }

        // 绘制左下角
        cornerPath.addLine(to: gPoint)
        if gPoint != hPoint {
            cornerPath.addCurve(to: hPoint, controlPoint1: gControlPoint, controlPoint2: hControlPoint)
        }

        // 绘制左上角
        cornerPath.addLine(to: aPoint)
        if aPoint != bPoint {
            cornerPath.addCurve(to: bPoint, controlPoint1: aControlPoint, controlPoint2: bControlPoint)
        }

        // 结束线路绘制
        cornerPath.close()

        return cornerPath
    }

}

