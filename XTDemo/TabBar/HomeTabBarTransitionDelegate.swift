//
/*
* ****************************************************************
*
* 文件名称 : HomeTabBarTransitionDelegate
* 作   者 : Created by 坤
* 创建时间 : 2022/3/14 11:22 AM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/14 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit

final class HomeTabBarTransitionDelegate: UIPercentDrivenInteractiveTransition {

// MARK: - 属性


// MARK: - 生命周期

    override init() {
        super.init()
    }
}

// MARK: - tabBarController 选择时的动画

extension HomeTabBarTransitionDelegate: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        DrAnimationTabScrollStyle()
    }
}
