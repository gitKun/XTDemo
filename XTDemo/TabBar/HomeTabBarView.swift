//
/*
* ****************************************************************
*
* 文件名称 : HomeTabBarView
* 作   者 : Created by 坤
* 创建时间 : 2022/3/14 11:34 AM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/14 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit

protocol HomeTabbarViewDelegate: NSObject {

    /// 是否可以选中(对应未登录时,选中特定的下标不跳转,而是进行其他操作)
    func homeTabBarView(_ barView: HomeTabBarView, canSelectedAt index: Int) -> Bool

    /// 选中某个 button
    func homeTabBarView(_ barView: HomeTabBarView, clickedAt index: Int)
}

class HomeTabBarView: UIView {

// MARK: - 属性

    weak var delegate: HomeTabbarViewDelegate?

    /// 默认选中的下标
    var defaultSelectedIndex: Int = 0 {
        didSet {
            if defaultSelectedIndex < btnArray.count {
                previousButton?.isSelected = false
                previousButton = btnArray[defaultSelectedIndex]
                previousButton?.isSelected = true
            }
        }
    }

    private let tabNormalImages = [
        UIImage.init(named: "tab_btn_square_def"),
        UIImage.init(named: "tab_btn_shujia_def"),
        UIImage.init(named: "btn_release"),
        UIImage.init(named: "tab_btn_shucheng_def"),
        UIImage.init(named: "tab_btn_me_def")
    ]

    private let tabActiveImages = [
        UIImage.init(named: "tab_btn_square_pre"),
        UIImage.init(named: "tab_btn_shujia_per"),
        UIImage.init(named: "btn_release"),
        UIImage.init(named: "tab_btn_shucheng_pre"),
        UIImage.init(named: "tab_btn_me_pre")
    ]

    private let tabTitles = ["沸点", "书架", nil, "书城", "我的"]

// MARK: - 生命周期 && Override

    override init(frame: CGRect) {
        super.init(frame: frame)

        initializeUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2

        let rect = bounds.insetBy(dx: -3, dy: -3)
        layer.shadowPath = UIBezierPath(rect: rect).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.15
    }

    // 不处理其他主题颜色的变更，使用 traitCollectionDidChange 替换
    /*override func tintColorDidChange() {
        super.tintColorDidChange()
        reloadApperance()
    }*/

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadApperance()
    }

// MARK: - TabBar 适配

    /*
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()

        if oldSafeAreaInsets != safeAreaInsets {
            oldSafeAreaInsets = safeAreaInsets

            invalidateIntrinsicContentSize()
            superview?.setNeedsLayout()
            superview?.layoutSubviews()
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        //if #available(iOS 11.0, *) {
        let bottomInset = safeAreaInsets.bottom
        if bottomInset > 0, size.height < 50, size.height + bottomInset < 90 {
            size.height += bottomInset
        }
        //}
        return size
    }
    */

// MARK: - UI elements

    var oldSafeAreaInsets = UIEdgeInsets.zero

    /// 当前选中的按钮
    private var previousButton: UIButton?

    private var btnArray: [UIButton] = []

}

// MARK:- 事件处理

extension HomeTabBarView {

    @objc private func tabbarButtonClicked(button: UIButton) {
        if previousButton == button { return }
        guard let index = btnArray.firstIndex(of: button) else { return }

        if let canSelected = delegate?.homeTabBarView(self, canSelectedAt: index) {
            if canSelected {
                previousButton?.isSelected = false
                button.isSelected = true
                previousButton = button
            }
        }

        delegate?.homeTabBarView(self, clickedAt: index)
    }

    // 当暗/亮模式转换时处理图标和背景色
    private func reloadApperance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        if isDark {
            showDarkStyle()
        } else {
            showLightStyle()
        }
    }

    private func showDarkStyle() {
        layer.shadowColor = UIColor.white.cgColor
    }

    private func showLightStyle() {
        layer.shadowColor = UIColor.white.cgColor
    }
}

// MARK: - 界面初始化

private extension HomeTabBarView {

    func initializeUI() {
        backgroundColor = .white

        translatesAutoresizingMaskIntoConstraints = false

        /*let button = DrButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.setImage(tabNormalImages[0], for: .normal)
        button.setImage(tabActiveImages[0], for: .selected)
        let title = "广场"
        button.setTitle(title, for: .normal)
        button.setTitleColor(.rgba(r: 51, g: 51, b: 51), for: .normal)
        button.setTitleColor(.rgba(r: 248, g: 111, b: 153), for: .selected)
        button.imagePosition = .bottom // .left .right .top
        button.spacingBetweenImageAndTitle = 5

        addSubview(button)
        需要布局代码*/

        let count = tabTitles.count
        btnArray.removeAll()
        for idx in 0..<count {
            let button = DrButton(type: .custom)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            button.setImage(tabNormalImages[idx], for: .normal)
            button.setImage(tabActiveImages[idx], for: .selected)
            if let title = tabTitles[idx] {
                button.setTitle(title, for: .normal)
                button.setTitleColor(.rgba(r: 51, g: 51, b: 51), for: .normal)
                button.setTitleColor(.rgba(r: 248, g: 111, b: 153), for: .selected)
                button.imagePosition = .top
                button.spacingBetweenImageAndTitle = 5
            }

            addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                button.leftAnchor.constraint(equalTo: previousButton?.rightAnchor ?? self.leftAnchor),
                button.topAnchor.constraint(equalTo: self.topAnchor),
                button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                button.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/CGFloat(count))
            ])

            previousButton = button

            button.addTarget(self, action: #selector(tabbarButtonClicked(button:)), for: .touchUpInside)

            btnArray.append(button)
        }

        // 默认第一个选中
        previousButton = btnArray.first
        previousButton?.isSelected = true
    }
}
