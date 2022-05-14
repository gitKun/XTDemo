//
/*
* ****************************************************************
*
* 文件名称 : DynamicListViewController
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:15 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import UIKit
import MJRefresh
import Combine


class DynamicListViewController: UIViewController {

// MARK: - 成员变量

    private var cancellable: Set<AnyCancellable> = []

    private let viewModel: DynamicListViewModelType = DynamicListViewModel()
    private let dataSource = DynamicListDataSource()

// MARK: - 生命周期 & override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        eventListen()
        bindViewModel()

        viewModel.input.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

// MARK: - UI 属性


    private var mjHeader: MJRefreshNormalHeader!
    private var mjFooter: MJRefreshBackNormalFooter!
}

// MARK: - 事件处理

extension DynamicListViewController {

    func eventListen() {

        self.mjHeader.refreshingBlock = { [unowned self] in
            self.viewModel.input.refreshDate()
        }

        self.mjFooter.refreshingBlock = { [unowned self] in
            self.viewModel.input.moreData(with: self.dataSource.nextCursor, needHot: self.dataSource.needHotDynamic)
        }
    }
}

// MARK: - 绑定 viewModel

extension DynamicListViewController {

    func bindViewModel() {
    }
}

// MARK: - UINavigationDelegate

extension DynamicListViewController: UINavigationControllerDelegate {

    // 判断 navBar 的隐藏显示
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // FIXME: - 这里直接隐藏了 tabbar
        if let tabBarController = self.tabBarController as? HomeTabBarController {
            tabBarController.setTabBarHidden(true, animated: true, animationTime: 0.25)
        }
    }
}

// MARK: - 布局UI元素

extension DynamicListViewController {

    func setupUI() {
        navigationItem.title = "沸点-热门"
        navigationController?.delegate = self


        #if false
        // 设置 mj_header
        let header = MJRefreshNormalHeader()
        header.stateLabel?.isHidden = true
        header.lastUpdatedTimeLabel?.isHidden = true
        self.tableView.mj_header = header
        self.mjHeader = header

        // 设置 mj_footer
        let footer = MJRefreshBackNormalFooter()
        footer.stateLabel?.isHidden = true
        self.tableView.mj_footer = footer
        self.mjFooter = footer
        self.mjFooter.isHidden = true
        #endif
    }
}
