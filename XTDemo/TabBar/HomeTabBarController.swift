//
/*
* ****************************************************************
*
* 文件名称 : HomeTabBarController
* 作   者 : Created by 坤
* 创建时间 : 2022/3/14 11:21 AM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/14 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import RxSwift
import RxCocoa
// import SnapKit
// import class DrBase.UIViewController

public class HomeTabBarController: UITabBarController {

// MARK: - 属性

    public var tintColor: UIColor? {
        didSet {
            customTabBar.tintColor = tintColor
            // customTabBar.reloadApperance()
        }
    }
    
    public var tabBarBackgroundColor: UIColor? {
        didSet {
            customTabBar.backgroundColor = tabBarBackgroundColor
            // customTabBar.reloadApperance()
        }
    }

    private let disposeBag = DisposeBag()

    private let animatedDelegate = HomeTabBarTransitionDelegate()

    fileprivate var bottomSpacing: CGFloat = 20
    fileprivate var tabBarHeight: CGFloat = 70
    fileprivate var horizontleSpacing: CGFloat = 20

// MARK: - 生命周期 && Override

    public override func viewDidLoad() {
        super.viewDidLoad()

        initializeUI()
        eventListen()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for child in tabBar.subviews {
            if let cls = NSClassFromString("UITabBarButton"), child.isMember(of: cls) {
                child.removeFromSuperview()
            }
        }
    }

    override open var selectedIndex: Int {
        didSet {
            // customTabBar.select(at: selectedIndex, notifyDelegate: false)
        }
    }

    override open var selectedViewController: UIViewController? {
        didSet {
            // customTabBar.select(at: selectedIndex, notifyDelegate: false)
        }
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    public override var shouldAutorotate: Bool {
        return false
    }

// MARK: - UI element

    let customTabBar: HomeTabBarView = {
        let view = HomeTabBarView()
        view.tag = 20001
        return view
    }()

    /// 底部安全距离的 view
    fileprivate lazy var smallBottomView: UIView = {
        let anotherSmallView = UIView()
        anotherSmallView.backgroundColor = .clear
        anotherSmallView.translatesAutoresizingMaskIntoConstraints = false
        anotherSmallView.tag = 10001

        return anotherSmallView
    }()

    private var barBottomConstraint: NSLayoutConstraint?
}

// MARK: - 事件处理

extension HomeTabBarController {

    private func eventListen() {
    }

    /// 设置 customTabBar 隐藏
    public func setTabBarHidden(_ isHidden: Bool, animated: Bool, animationTime: TimeInterval = 0.25) {

        let hasHidden = (self.additionalSafeAreaInsets == .zero)

        if hasHidden == isHidden { return }

        if isHidden {
            self.additionalSafeAreaInsets = .zero
            self.barBottomConstraint?.constant = self.tabBarHeight
        } else {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.tabBarHeight + self.bottomSpacing, right: 0)
            self.barBottomConstraint?.constant = 0
        }
        if animated {
            UIView.animate(withDuration: animationTime) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
}

// MARK: - HomeTabbarViewDelegate

extension HomeTabBarController: HomeTabbarViewDelegate {

    func homeTabBarView(_ barView: HomeTabBarView, clickedAt index: Int) {
        if index < 2 {
            selectedIndex = index
        } else if index > 2 {
            selectedIndex = index - 1
        }
    }

    func homeTabBarView(_ barView: HomeTabBarView, canSelectedAt index: Int) -> Bool {
        if index == 2 {
            return false
        }
        return true
    }
}

// MARK: - 界面初始化

private extension HomeTabBarController {

    func initializeUI() {

        initializeTabBarView()
        setupChildViewControllers()
    }

    func initializeTabBarView() {
        // 增加自己safe
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpacing, right: 0)

        tabBar.isHidden = true

        // 添加底部的按钮
        view.addSubview(smallBottomView)
        smallBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let cr: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            cr = smallBottomView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: tabBarHeight)
        } else {
            cr = smallBottomView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: tabBarHeight)
        }
        cr.priority = .defaultHigh
        cr.isActive = true

        smallBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        smallBottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        customTabBar.delegate = self
        view.addSubview(customTabBar)

        barBottomConstraint = customTabBar.bottomAnchor.constraint(equalTo: smallBottomView.topAnchor, constant: 0)
        barBottomConstraint?.isActive = true
        customTabBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontleSpacing).isActive = true
        customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight).isActive = true

        view.bringSubviewToFront(customTabBar)
        view.bringSubviewToFront(smallBottomView)

        customTabBar.tintColor = tintColor
    }

    func setupChildViewControllers() {

        // 沸点
        let dynamicVC = DynamicListViewController()
        let dynamicNav = UINavigationController(rootViewController: dynamicVC)
        addChild(dynamicNav)

        // 书架
        let bookcaseVC = UIViewController()
        bookcaseVC.view.backgroundColor = UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
        let bookcaseNav = UINavigationController(rootViewController: bookcaseVC)
        addChild(bookcaseNav)

        // 消息
        let VC2 = SimpleRegxViewController()
        VC2.view.backgroundColor = UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
        let messageNav = UINavigationController(rootViewController: VC2)
        addChild(messageNav)

        // 我的
        let textureDemoVC = TextureDemoViewController()
        let textureDemoNav = UINavigationController(rootViewController: textureDemoVC)
        addChild(textureDemoNav)

        viewControllers = [dynamicNav, bookcaseNav, messageNav, textureDemoNav]

        // 设置默认选中第一个
        selectedIndex = 0

        // 配置动画属性
        if let vcArray = viewControllers {
            var vcIdx = 0
            for vc in vcArray {
                vc.dr_index = vcIdx
                vcIdx += 1
            }
        }

        delegate = animatedDelegate
    }
}
