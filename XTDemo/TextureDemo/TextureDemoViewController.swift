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
import RxSwift
import Moya

class TextureDemoViewController: ASDKViewController<ASDisplayNode> {

// MARK: - 成员变量

    private var modelList: [DynamicListModel] = []

    private let disposeBag = DisposeBag()

    private let testNetWork = PublishSubject<Void>()

// MARK: - 生命周期 & override

    override init() {
        let node = ASDisplayNode.init()
        node.backgroundColor = .white
        super.init(node: node)

//        self.node.addSubnode(self.tableNode)
//        self.node.layoutSpecBlock = { [unowned self] node, constrainedSize in
//            return ASInsetLayoutSpec(insets: .zero, child: self.tableNode)
//        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeUI()
        eventListen()
        bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        testNetWork.onNext(())
        super.touchesBegan(touches, with: event)
    }

// MARK: - UI 属性

    private let tableNode: ASTableNode = {
        let node = ASTableNode.init()
        node.backgroundColor = .clear
        node.leadingScreensForBatching = 4
        node.view.separatorStyle = .none
        return node
    }()
}

// MARK: - 事件处理

extension TextureDemoViewController {

    func eventListen() {
    }
}

// MARK: - 绑定 viewModel

extension TextureDemoViewController {

    func bindViewModel() {
        DispatchQueue.global(qos: .default).async {
            guard let dataUrl = Bundle.main.url(forResource: "xt_dynamic_list_0", withExtension: "json") else { return }
            do {
                let jsonData = try Data(contentsOf: dataUrl)
                let wrappedModel = try JSONDecoder().decode(XTListResultModel.self, from: jsonData)
                self.modelList = (wrappedModel.data ?? [])
                DispatchQueue.main.async {
                    self.tableNode.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        testNetWork.asObserver().subscribe(onNext: { [weak self]  _ in
            //self?.testDecoderTopicList()
            self?.testQueryNetwork()
        }).disposed(by: disposeBag)
    }

    func testDecoderTopicList() {
        guard let dataUrl = Bundle.main.url(forResource: "xt_topic_recommend_list", withExtension: "json") else { return }
        do {
            let jsonData = try Data(contentsOf: dataUrl)
            let jsonDict = (try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)) as? [String: Any]
            print(jsonDict ?? [:])
            let wrappedModel = try JSONDecoder().decode(TopicListModel.self, from: jsonData)
            print(wrappedModel)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testQueryNetwork() {
        DynamicNetworkService.topicListRecommend.memoryCacheIn(seconds: 60 * 3).requeset().map(TopicListModel.self).subscribe(onSuccess: { wrappedModel in
            print(wrappedModel.data?.count ?? 0)
        }, onFailure: { error in
            print(error)
        }).disposed(by: self.disposeBag)
    }
}

// MARK: - ASTableDelegate

extension TextureDemoViewController: ASTableDelegate {
    
}

// MARK: - ASTableDataSource

extension TextureDemoViewController: ASTableDataSource {

    func numberOfSections(in tableNode: ASTableNode) -> Int { 1 }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        modelList.count// == 0 ? 0 : 1
    }

    // 有个 block 版本的, 异步返回 cellNode 时使用, 非 block 版本默认在主线程创建 cellNode
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cellNode = DynamicListCellNode()
        cellNode.configure(with: modelList[indexPath.row])
        cellNode.delegate = self
        return cellNode
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
    }
}
