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
import AsyncDisplayKit
import Moya
import Combine
import MJRefresh

class TextureDemoViewController: ASDKViewController<ASDisplayNode> {

// MARK: - 成员变量

    private var modelList: [DynamicDisplayType] = []

    private let viewModel: TextureDemoViewModelType = TextureDemoViewModel()
    private var cancellable: Set<AnyCancellable> = []

// MARK: - 生命周期 & override

    override init() {
        let node = ASDisplayNode.init()
        node.backgroundColor = .white
        node.addSubnode(self.tableNode)
        super.init(node: node)

        node.layoutSpecBlock = { [unowned self] node, constrainedSize in
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

    private let tableNode: ASTableNode = {
        let node = ASTableNode.init()
        node.backgroundColor = .clear
        node.leadingScreensForBatching = 4
        node.view.separatorStyle = .none
        return node
    }()

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
        self.tableNode.reloadData()
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

        // 测试多次订阅,
        /*viewModel.output.newDataPublisher
            .sink { list in
                print(list[1])
            }
            .store(in: &cancellable)*/

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

// MARK: - ASTableDelegate

extension TextureDemoViewController: ASTableDelegate {
    
}

// MARK: - ASTableDataSource

extension TextureDemoViewController: ASTableDataSource {

    func numberOfSections(in tableNode: ASTableNode) -> Int { 1 }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        modelList.count// == 0 ? 0 : 2
    }

    // 有个 block 版本的, 异步返回 cellNode 时使用, 非 block 版本默认在主线程创建 cellNode
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let model = modelList[indexPath.row]

        switch model {
        case .dynamic(let dynModel):
            let cellNode = DynamicListCellNode()
            cellNode.configure(with: dynModel)
            cellNode.delegate = self
            return cellNode
        case .topicList(let topic):
            let cellNoed = DynamicTopicWrapperCellNode()
            cellNoed.configure(with: topic)
            return cellNoed
        case .hotList(let list):
            let cellNode = DynamicListCellNode()
            cellNode.configure(with: list[0])
            cellNode.delegate = self
            return cellNode
        }
    }
}

// MARK: - DynamicListCellNodeDelegate

extension TextureDemoViewController: DynamicListCellNodeDelegate {

    func listCellNode(_ cellNodel: DynamicListCellNode, showDiggForMsg: String?) {
        showToast("需要实现跳转到列表界面!")
    }

    func listCellNode(_ cellNodel: DynamicListCellNode, selectedView: UIView, selectedImage at: Int, allImages: [String]) {
        let imgUrls: [URL] = allImages.compactMap { URL(string: $0) }
        let idx = imgUrls.count > at ? at : 0
        showXTPhotoBrowser(from: selectedView, imagesUrl: imgUrls, selsctIndex: idx)
    }
}

// MARK: - 布局UI元素

extension TextureDemoViewController {

    func initializeUI() {
        navigationItem.title = "Texture 部分示例"

        // 设置 tableNode
        self.tableNode.view.separatorInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        self.tableNode.contentInset = .init(top: 0, left: 0, bottom: k_dr_BottomSafeHeight + 10, right: 0)

        // 设置 mj_header
        let header = DrRefreshNormalHeader()
        header.setTitle("下拉即可刷新", for: .idle)
        header.setTitle("松开即可更新", for: .pulling)
        header.setTitle("数据加载中", for: .refreshing)
        header.lastUpdatedTimeLabel?.isHidden = true
        tableNode.view.mj_header = header
        mjHeader = header

        // 设置 mj_footer
        let footer = MJRefreshBackNormalFooter()
        self.tableNode.view.mj_footer = footer
        self.mjFooter = footer
        footer.isHidden = true
    }
}
