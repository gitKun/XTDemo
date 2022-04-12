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

class TextureDemoViewController: ASDKViewController<ASDisplayNode> {

// MARK: - 成员变量

    private var modelList: [DynamicDisplayType] = []

    private var cancellable: Set<AnyCancellable> = []

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        // testZipLocalDatasourc()
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
        testZipLocalDatasourc()
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
        DynamicNetworkService.topicListRecommend
            .memoryCacheIn()
            .request()
            .map(TopicListModel.self)
            .sink { complete in
                switch complete {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { topicWrapped in
                print(topicWrapped.data?.count ?? 0)
            }.store(in: &cancellable)
    }

    func testZipLocalDatasourc() {

        let dynamicPath = Bundle.main.path(forResource: "xt_dynamic_list_0.json", ofType: nil)
        let dynamicPublisher = JsonDataPublisher<XTListResultModel>(filePaht: dynamicPath)
            .map { Result<XTListResultModel, JsonDataError>.success($0) }
            .eraseToAnyPublisher()
            .catch { Just<Result<XTListResultModel, JsonDataError>>(.failure($0)).eraseToAnyPublisher() }
            .eraseToAnyPublisher()

        let topicPath = Bundle.main.path(forResource: "xt_topic_recommend_list.json", ofType: nil)
        let topicPublisher = JsonDataPublisher<TopicListModel>(filePaht: topicPath)
            .map { Result<TopicListModel, JsonDataError>.success($0) }
            .eraseToAnyPublisher()
            .catch { Just<Result<TopicListModel, JsonDataError>>(.failure($0)) }
            .eraseToAnyPublisher()

        let showSubject = Publishers.Zip(dynamicPublisher, topicPublisher)
            .map { (dynamicResult, topicResult) -> [DynamicDisplayType] in
                var resultArray: [DynamicDisplayType] = []
                switch topicResult {
                case .success(let wrappedModel):
                    if let list = wrappedModel.data, !list.isEmpty {
                        resultArray.append(.topicList(list))
                    }
                case .failure(let error):
                    print(error)
                }

                switch dynamicResult {
                case .success(let wrappedModel):
                    if let list = wrappedModel.data {
                        resultArray.append(contentsOf: list.map { .dynamic($0) })
                    }
                case .failure(let error):
                    print("\(error)")
                }

                return resultArray
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        // FIXED: - receive(on: .main) 和 subscribe(on: .main) 的
        // 区别见: https://trycombine.com/posts/subscribe-on-receive-on/

        showSubject
            //.receive(on: RunLoop.main)
            .sink { [weak self] list in
                self?.modelList = list
                self?.tableNode.reloadData()
            }
            .store(in: &cancellable)
    }
}

fileprivate enum TestError: Swift.Error {
    case jsonData(String)
    case dynamicListNoData(String)
    case topicList(String)
    case justFailure
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
    }
}


// MARK: - 创建自己的 Publisher

fileprivate enum JsonDataError: Error {
    case noFile
    case noData
    case noValidateData
    case modelMapping
}

fileprivate final class JsonDataPublisher<Output: Decodable>: Publisher {

    typealias Failure = JsonDataError

    private let filePath: String?

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = JsonDataSubscription(filePath: filePath, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }

    init(filePaht: String?) {
        self.filePath = filePaht
    }
}


fileprivate final class JsonDataSubscription<S: Subscriber>: Combine.Subscription where S.Input: Decodable, S.Failure == JsonDataError {

    private let filePath: String?
    private let subscriber: S?
    private var task: DispatchWorkItem?

    init(filePath: String?, subscriber: S?) {
        self.filePath = filePath
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else { return }
        guard let subscriber = subscriber else { return }

        guard let filePath = filePath, FileManager.default.fileExists(atPath: filePath) else {
            subscriber.receive(completion: .failure(.noFile))
            return
        }

        let topicFileUrl = URL(fileURLWithPath: filePath)

        task = DispatchWorkItem {
            guard let jsonData = try? Data(contentsOf: topicFileUrl) else {
                subscriber.receive(completion: .failure(.noData))
                return
            }

            do {
                let wrappedModel = try JSONDecoder().decode(S.Input.self, from: jsonData)
                _ = subscriber.receive(wrappedModel)
                subscriber.receive(completion: .finished)
            } catch let error {
                debugPrint(error)
                // TODO: - 根据 error 区分 noValidateData 和 modelMapping
                subscriber.receive(completion: .failure(.modelMapping))
            }
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1), execute: task!)
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}



fileprivate extension Publishers {

    /// 十分简单的一次模仿, 无实际使用价值
    struct IsMainThreed: Publisher {
        typealias Output = Bool
        typealias Failure = Never

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            subscriber.receive(subscription: Subscriptions.empty)
            let inMain = Thread.isMainThread
            DispatchQueue.main.async {
                _ = subscriber.receive(inMain)
            }
        }
    }
}
