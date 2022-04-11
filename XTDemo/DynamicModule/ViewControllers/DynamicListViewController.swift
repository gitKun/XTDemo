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
import AsyncDisplayKit
import MJRefresh
import Combine


class DynamicListViewController: ASDKViewController<ASDisplayNode> {

// MARK: - 成员变量

    private var cancellable: Set<AnyCancellable> = []

    private let viewModel: DynamicListViewModelType = DynamicListViewModel()
    private let dataSource = DynamicListDataSource()

// MARK: - 生命周期 & override

    override init() {
        let node = ASDisplayNode.init()
        node.backgroundColor = .white
        super.init(node: node)

        self.node.addSubnode(self.tableNode)
        self.node.layoutSpecBlock = { [unowned self] node, constrainedSize in
            return ASInsetLayoutSpec(insets: .zero, child: self.tableNode)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeUI()
        eventListen()
        bindViewModel()

        viewModel.input.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

// MARK: - UI 属性

    private let tableNode: ASTableNode = {
        let node = ASTableNode.init()
        node.backgroundColor = .clear
        node.leadingScreensForBatching = 4
        node.view.separatorStyle = .none
        return node
    }()

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
        viewModel.output.newData.sink { [weak self] wrappedModel in
            self?.dataSource.newData(from: wrappedModel)
            self?.tableNode.reloadData()
        }.store(in: &cancellable)

        viewModel.output.moreData.sink { [weak self] wrappedModel in
            if let insertIndexPath = self?.dataSource.moreData(from: wrappedModel), !insertIndexPath.isEmpty {
                self?.tableNode.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.automatic)
            }
        }.store(in: &cancellable)

        viewModel.output.endRefresh.sink { [weak self] _ in
            self?.mjHeader.endRefreshing()
            self?.mjFooter.endRefreshing()
            self?.mjFooter.isHidden = false
        }.store(in: &cancellable)

        viewModel.output.hasMoreData.sink { [weak self] hasMore in
            if hasMore {
                self?.mjFooter.endRefreshing()
            } else {
                self?.mjFooter.endRefreshingWithNoMoreData()
            }
        }.store(in: &cancellable)

        viewModel.output.showError.sink { [weak self] message in
            // FIXME: - 接入 HUD / Toast / 什么都不做, 展示空白视图 ??
            self?.showToast(message)
        }.store(in: &cancellable)
    }
}

// MARK: - ASTableDelegate

extension DynamicListViewController: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        if let cNode = node as? DynamicListCellNode, cNode.delegate == nil {
            cNode.delegate = self
        }
    }
}

// MARK: - DynamicListCellNodeDelegate

extension DynamicListViewController: DynamicListCellNodeDelegate {

    func listCellNode(_ cellNodel: DynamicListCellNode, showDiggForMsg: String?) {
        showToast("需要实现跳转到列表界面!")
    }

    func listCellNode(_ cellNodel: DynamicListCellNode, selectedView: UIView, selectedImage at: Int, allImages: [String]) {
        let imgUrls: [URL] = allImages.compactMap { URL(string: $0) }
        let idx = imgUrls.count > at ? at : 0
        showXTPhotoBrowser(from: selectedView, imagesUrl: imgUrls, selsctIndex: idx)
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

    func initializeUI() {
        navigationItem.title = "沸点-热门"
        navigationController?.delegate = self

        // 设置 tableNode
        tableNode.view.separatorInset = .init(top: 0, left: 0, bottom: 20.sizeFromIphone6, right: 0)
        tableNode.delegate = self
        tableNode.dataSource = self.dataSource
        tableNode.contentInset = .init(top: 0, left: 0, bottom: k_dr_iSiPhoneX ? 34 + 10.sizeFromIphone6 : 10.sizeFromIphone6, right: 0)

        // 设置 mj_header
        let header = MJRefreshNormalHeader()
        header.stateLabel?.isHidden = true
        header.lastUpdatedTimeLabel?.isHidden = true
        self.tableNode.view.mj_header = header
        self.mjHeader = header

        // 设置 mj_footer
        let footer = MJRefreshBackNormalFooter()
        footer.stateLabel?.isHidden = true
        self.tableNode.view.mj_footer = footer
        self.mjFooter = footer
        self.mjFooter.isHidden = true
    }
}
