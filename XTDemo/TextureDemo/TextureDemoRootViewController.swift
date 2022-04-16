//
/*
* ****************************************************************
*
* 文件名称 : TextureDemoRootViewController
* 作   者 : Created by 坤
* 创建时间 : 2022/4/15 19:16
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/15 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import Combine


class TextureDemoRootViewController: UIViewController {

// MARK: - 成员变量


// MARK: - 生命周期 & override

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeUI()
        eventListen()
        bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

// MARK: - 计算属性 & lazy

    var buttonSubscriber: Subscribers.Sink<UIControl, Never>!

// MARK: - UI 属性

    private let showDemoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.systemBrown, for: .normal)
        button.setTitle("显示Demo页面", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22.5
        // button.layer.masksToBounds = true
        return button
    }()

}

// MARK: - 事件处理

extension TextureDemoRootViewController {

    func eventListen() {

        buttonSubscriber = .init(receiveCompletion: { _ in
            print("TextureDemoRootViewController buttonSubscriber finished!")
        }, receiveValue: { [weak self] btn in
            self?.navigationController?.pushViewController(TextureDemoViewController(), animated: true)
        })

        showDemoButton.publisher(forAction: .touchUpInside)
            .receive(subscriber: buttonSubscriber)
    }
}

// MARK: - 绑定 viewModel

extension TextureDemoRootViewController {

    func bindViewModel() {
    }
}

// MARK: - 布局UI元素

extension TextureDemoRootViewController {

    func initializeUI() {
        view.backgroundColor = .systemTeal

        view.addSubview(showDemoButton)
        showDemoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showDemoButton.widthAnchor.constraint(equalToConstant: 240),
            showDemoButton.heightAnchor.constraint(equalToConstant: 45),
            showDemoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showDemoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

