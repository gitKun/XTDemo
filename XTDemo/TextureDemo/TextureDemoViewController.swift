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

    private let testSubject = PublishSubject<Void>()
    private var shouldShowError = false

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
        testSubject.onNext(())
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

        testSubject.asObserver().subscribe(onNext: { [weak self]  _ in
            // self?.testDecoderTopicList()
            // self?.testQueryNetwork()
            self?.testZipLocalDatasourc()
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
        DynamicNetworkService.topicListRecommend
            //.memoryCacheIn(seconds: 60 * 3)
            .onStorage(TopicListModel.self, onDisk: { listModel in
                print(listModel)
            })
            .request()
            .map(TopicListModel.self)
            .subscribe(onSuccess: { wrappedModel in
                print(wrappedModel.data?.count ?? 0)
            }, onFailure: { error in
                print(error)
            }).disposed(by: self.disposeBag)
    }

    func testZipLocalDatasourc() {

        let dynamicSubject = Single<XTListResultModel>.create { single in
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                if let dynamicFileUrl = Bundle.main.url(forResource: "xt_dynamic_list_0", withExtension: "json") {
                    do {
                        let jsonData = try Data(contentsOf: dynamicFileUrl)
                        let wrappedModel = try JSONDecoder().decode(XTListResultModel.self, from: jsonData)
                        single(.success(wrappedModel))
                        //single(.failure(TestError.justFailure))
                    } catch let error {
                        single(.failure(error))
                    }
                } else {
                    single(.failure(TestError.jsonData("Dynamic file url error!")))
                }
            }

            return Disposables.create {
                print("Read dynamic file dispose! ____#")
            }
        }.asSignal(onErrorJustReturn: .init()).asObservable()


        let topicSubject = Observable<TopicListModel>.create { obser in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let topicFileUrl = Bundle.main.url(forResource: "xt_topic_recommend_list", withExtension: "json") {
                    do {
                        let jsonData = try Data(contentsOf: topicFileUrl)
                        let wrappedModel = try JSONDecoder().decode(TopicListModel.self, from: jsonData)
                        obser.onNext(wrappedModel)
                    } catch let error {
                        obser.onError(error)
                    }
                } else {
                    obser.onError(TestError.jsonData("TopicList file url error!"))
                }
            }

            return Disposables.create {
                print("Read topicList file dispose! ____#")
            }
        }.asSignal(onErrorJustReturn: .init()).asObservable()

        let showSubject = Observable.zip(dynamicSubject, topicSubject).flatMap { (dynamicWrapped, topicWrapped) -> Observable<[DynamicDisplayType]> in

            var resultArray: [DynamicDisplayType] = []
            if let data = dynamicWrapped.data {
                resultArray.append(contentsOf: data.map { .dynamic($0) })
            }

            if let topicList = topicWrapped.data {
                if resultArray.count > 3 {
                    resultArray.insert(.topicList(topicList), at: 3)
                } else {
                    resultArray.append(.topicList(topicList))
                }
            }
            return .just(resultArray)
        }

        showSubject.subscribe(onNext: { list in
            debugPrint(list)
        }, onError: { error in
            if let _ = error as? TestError {
                print("TestError! ____#")
            }
            print(error)
        }).disposed(by: disposeBag)

//        showSubject.subscribe(onSuccess: { displayList in
//            debugPrint(displayList)
//        }, onFailure: { error in
//            if let testError = error as? TestError {
//                print(testError)
//            }
//            print(error)
//        }).disposed(by: disposeBag)
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
