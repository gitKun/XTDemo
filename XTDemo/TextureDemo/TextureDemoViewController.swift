//
/*
* ****************************************************************
*
* 文件名称 : TextureDemoViewController
* 作   者 : Created by 坤
* 创建时间 : 2022/3/25 11:05 AM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/25 初始版本
*
* ****************************************************************
*/

import Foundation
import Moya
import Combine
import MJRefresh


class TextureDemoViewController: UIViewController {

// MARK: - 成员变量

    private var modelList: [DynamicDisplayType] = []

    private let viewModel: TextureDemoViewModelType = TextureDemoViewModel()
    private var cancellable: Set<AnyCancellable> = []

// MARK: - 生命周期 & override


    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        eventListen()
        bindViewModel()

        // FIXED: - 使用 Just 替换 mjHeader.beginRefreshing()
        Just<Void>(()).receive(subscriber: viewModel.input.viewDidLoadSubscriber)
    }

    deinit {
        print("\(type(of: self)) deinit! ____#")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

// MARK: - UI 属性

    private var mjHeader: MJRefreshHeader!
    private var mjFooter: MJRefreshFooter!
}

// MARK: - 事件处理

private extension TextureDemoViewController {

    func eventListen() {

        mjHeader.publisherRefreshing
            .map { _ in }
            .receive(subscriber: viewModel.input.refreshSubscriber)

        mjFooter.publisherRefreshing
            .map { _ in }
            .receive(subscriber: viewModel.input.moreDataSubcriber)
    }

    func insertData(with list: [DynamicDisplayType]) {
        
    }

    func reloadData(with list: [DynamicDisplayType]) {
        self.mjFooter.isHidden = false
        self.modelList = list
        //self.tableView.reloadData()
    }
}

// MARK: - 绑定 viewModel

extension TextureDemoViewController {

    func bindViewModel() {

        viewModel.output.newDataPublisher
            .sink { [weak self] list in
                self?.reloadData(with: list)
            }
            .store(in: &cancellable)

        let headerSubscriber = mjHeader.subscriber()
        headerSubscriber.store(in: &cancellable)
        viewModel.output.endRefreshPublisher
            .receive(subscriber: headerSubscriber)

        viewModel.output.moreDataPublisher
            .sink { [weak self] list in
                self?.insertData(with: list)
            }
            .store(in: &cancellable)

        let footerSubscriber = mjFooter.subscriber()
        footerSubscriber.store(in: &cancellable)
        viewModel.output.endMoreRefreshPublisher
            .receive(subscriber: footerSubscriber)

        viewModel.output.toastPublisher
            .sink { [weak self] msg in
                self?.toast.showCenter(message: msg)
            }
            .store(in: &cancellable)
    }
}

// MARK: - 布局UI元素

extension TextureDemoViewController {

    func setupUI() {
        navigationItem.title = "Texture 部分示例"

        #if false
        // 设置 tableView
        self.tableView.separatorInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: k_dr_BottomSafeHeight + 10, right: 0)

        // 设置 mj_header
        let header = DrRefreshNormalHeader()
        header.setTitle("下拉即可刷新", for: .idle)
        header.setTitle("松开即可更新", for: .pulling)
        header.setTitle("数据加载中", for: .refreshing)
        header.lastUpdatedTimeLabel?.isHidden = true
        tableView.view.mj_header = header
        mjHeader = header

        // 设置 mj_footer
        let footer = MJRefreshBackNormalFooter()
        tableView.view.mj_footer = footer
        mjFooter = footer
        footer.isHidden = true
        #endif
    }
}
