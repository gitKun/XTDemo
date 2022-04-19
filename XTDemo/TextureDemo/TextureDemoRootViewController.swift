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

    var canShow = false

    private var count = 0

    private var cancellable: Set<AnyCancellable> = []
    private var testSubject = PassthroughSubject<Void, Never>()

// MARK: - 生命周期 & override

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeUI()
        eventListen()
        bindViewModel()
    }

    deinit {
        print("TextureDemoRootViewController deinit! ____#")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

// MARK: - 计算属性 & lazy

    var buttonSubscriber: Subscribers.Sink<String, Never>!

// MARK: - UI 属性

    private var showDemoButton: UIButton!
    private var addButton: UIButton!
    private var countButton: UIButton!

}

// MARK: - 事件处理

extension TextureDemoRootViewController {

    func eventListen() {

        if !canShow {

            showDemoButton.publisher(forAction: .touchUpInside)
                .sink { [weak self] _ in
                    let demoVC = TextureDemoViewController()
                    self?.navigationController?.pushViewController(demoVC, animated: true)
                }
                .store(in: &cancellable)
            /*showDemoButton.publisher(forAction: .touchUpInside)
                .sink { [weak self] _ in
                    let vc = TextureDemoRootViewController()
                    vc.canShow = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                .store(in: &cancellable)*/
        } else {
            
        }
    }
}

// MARK: - 绑定 viewModel

extension TextureDemoRootViewController {

    func bindViewModel() {

        // 模仿
//        testSubject
//            .map { _ in Bool.random() }
//            .receive(subscriber: TestSubscriber())
    }
}

// MARK: - 布局UI元素

extension TextureDemoRootViewController {

    func initializeUI() {

        view.backgroundColor = canShow ? .systemTeal : .systemBrown
        navigationItem.title = canShow ? "计数器页面" : "首页"

        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10

        if !canShow {
            showDemoButton = createButton(with: "显示Demo页面")
            stackView.addArrangedSubview(showDemoButton)
        } else {
            addButton = createButton(with: "计数加一")
            countButton = createButton(with: "0", titleColor: .systemRed)
            stackView.addArrangedSubview(addButton)
            stackView.addArrangedSubview(countButton)
        }

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalToConstant: 240),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func createButton(with title: String, titleColor: UIColor = .systemBrown) -> UIButton {
        let button = TestButton(type: .custom)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22.5
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([button.heightAnchor.constraint(equalToConstant: 45)])
        // button.layer.masksToBounds = true
        return button
    }
}


/// 应当遵守官方备注: 在 cancel 释放内存(引用).
/// 对于自定义的 Subscriber 应该和官方的 `Sink` 类似, 遵守 `Cancellable`
/// 在传入 `Publisher` 的 `receiver(subscriber:)` 后
/// 必须在适合的时机调用 `cancel`, 如 `store(in: )`
fileprivate final class TestSubscriber: Combine.Subscriber, Combine.Cancellable {

    typealias Input = String
    typealias Failure = Never

    // FIXED: - 需要强引用一次 subscription, 保证其生命周期内 subscriptin 一直存在
    var subscription: Subscription?

    deinit {
        subscription?.cancel()
        print("TestSubscriber deinit! ____#")
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
        // @note: - 这里可以限制请求次数
        subscription.request(.unlimited)
    }

    func receive(_ input: String) -> Subscribers.Demand {
        print("TestSubscriber 接收到值: \(input)")
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("TestSubscriber 结束订阅! ____&")
    }

    func cancel() {
        // FIXED: - 对于 `Publishers/Share` 或者 `Publishers/Multicast` 必须调用 cancel
        subscription?.cancel()
        subscription = nil
    }
}
