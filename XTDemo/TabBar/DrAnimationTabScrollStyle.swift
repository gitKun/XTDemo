//
/*
* ****************************************************************
*
* 文件名称 : DrAnimationTabScrollStyle
* 作   者 : Created by 坤
* 创建时间 : 2022/3/14 11:23 AM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/14 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit

private let kDrTransitionTime: TimeInterval = 0.5

class DrAnimationTabScrollStyle: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        kDrTransitionTime
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let fromView = fromVC.view,
              let toView = toVC.view
        else {
            return
        }

        let toVCIndex = toVC.dr_index
        let fromVCIndex = fromVC.dr_index

        assert(toVCIndex != fromVCIndex, "请为给您的 controller 的 dr_index 正确赋值! 当前值 toVcIdx = \(toVCIndex), fromVcId = \(fromVCIndex) ____#")

        let containView = transitionContext.containerView
        let targetWidht = containView.bounds.width
        let targetHeight = containView.bounds.height

        if toVCIndex > fromVCIndex {
            toView.frame = CGRect(x: targetWidht, y: 0, width: targetWidht, height: targetHeight)
            containView.addSubview(toView)

            UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
                fromView.transform = fromView.transform.translatedBy(x: -targetWidht, y: 0)
                toView.transform = toView.transform.translatedBy(x: -targetWidht, y: 0)
            } completion: { _ in
                transitionContext.completeTransition(true)
            }
        } else if toVCIndex < fromVCIndex {
            toView.frame = CGRect(x: -targetWidht, y: 0, width: targetWidht, height: targetHeight)
            containView.addSubview(toView)

            UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
                fromView.transform = fromView.transform.translatedBy(x: targetWidht, y: 0)
                toView.transform = toView.transform.translatedBy(x: targetWidht, y: 0)
            } completion: { _ in
                transitionContext.completeTransition(true)
            }
        }
    }
}
