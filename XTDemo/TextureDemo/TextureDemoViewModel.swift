//
/*
* ****************************************************************
*
* 文件名称 : TextureDemoViewModel
* 作   者 : Created by 坤
* 创建时间 : 2022/3/26 12:04 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/26 初始版本
*
* ****************************************************************
*/

import Foundation
import Combine

fileprivate var kDynamicFileIndex = 0

protocol TextureDemoViewModelInputs {

    var viewDidLoadSubscriber: AnySubscriber<Void, Never> { get }
    var refreshSubscriber: AnySubscriber<Void, Never> { get }
    var moreDataSubcriber: AnySubscriber<Void, Never> { get }
}

protocol TextureDemoViewModelOutputs {

    var newDataPublisher: AnyPublisher<[DynamicDisplayType], Never> { get }
    var endRefreshPublisher: AnyPublisher<Void, Never> { get }
    var moreDataPublisher: AnyPublisher<[DynamicDisplayType], Never> { get }
    var endMoreRefreshPublisher: AnyPublisher<Bool, Never> { get }
    var toastPublisher: AnyPublisher<String, Never> { get }
}

protocol TextureDemoViewModelType {
    var input: TextureDemoViewModelInputs { get }
    var output: TextureDemoViewModelOutputs { get }
}

final class TextureDemoViewModel: TextureDemoViewModelType, TextureDemoViewModelInputs, TextureDemoViewModelOutputs {

    var input: TextureDemoViewModelInputs { self }
    var output: TextureDemoViewModelOutputs { self }

    init() {
    }

    deinit {

        // 通知 外部的 subscriber 事件已经结束
        refreshSubject.send(completion: .finished)
        topicSubject.send(completion: .finished)
        // moreDataSubcriber 中包含了 moreDataSubject 因此不 send finished 也会释放.
        moreDataSubject.send(completion: .finished)

        // 确保自己的 subscriber 得到释放
        refreshSubscriber.receive(completion: .finished)
        moreDataSubcriber.receive(completion: .finished)
        print("\(type(of: self)) deinit! ____#")
    }

// MARK: - Inputs

    fileprivate let refreshSubject = PassthroughSubject<Void, Never>()
    fileprivate let topicSubject = PassthroughSubject<Void, Never>()

    // FIXED: - 自己创建的 subscriber 应该在 deinit 中释放资源
    // FIXED: - subsecriber 可以多次接收 Completed 事件, 只会相应第一次接收
    lazy private(set) var refreshSubscriber: AnySubscriber<Void, Never> = {
        let sinkSubscriber = Subscribers.Sink<Void, Never>.init { _ in
            print("refresh Sink finished! ____&")
        } receiveValue: { [weak self] _ in
            kDynamicFileIndex = 0
            self?.queryNewData()
        }

        return .init(sinkSubscriber)
    }()
    // FIXED: - 使用 lazy 会造成对 Just 的第一次订阅无效.
    /*lazy private(set) var refreshSubscriber: AnySubscriber<Void, Never> = {
        self.viewDidLoadSubscriber
    }()*/

    // Just 传入的不需要手动释放
    var viewDidLoadSubscriber: AnySubscriber<Void, Never> {
        let sinkSubscriber = Subscribers.Sink<Void, Never>.init { _ in
            print("viewDidLoad Sink finished! ____&")
        } receiveValue: { [weak self] _ in
            self?.queryNewData()
        }

        return .init(sinkSubscriber)
    }

    fileprivate let moreDataSubject = PassthroughSubject<Void, Never>()
    lazy private(set) var moreDataSubcriber: AnySubscriber<Void, Never> = {
        self.moreDataSubject.asAnySubscriber()
    }()

// MARK: - Outputs

    // FIXED: - 必须使用存储属性, share() 才能保证多次订阅不会产生多次的请求
    private lazy var newDataResultPublisher: AnyPublisher<Result<[DynamicDisplayType], BundleJsonDataError>, Never> = {
        self.createNewDataPublisher()
            .share()
            .eraseToAnyPublisher()
    }()

    var newDataPublisher: AnyPublisher<[DynamicDisplayType], Never> {
        return self.newDataResultPublisher
            .compactMap { result -> [DynamicDisplayType]? in
                if case .success(let list) = result {
                    return list
                }
                return nil
            }
            .onMainScheduler()
    }

    /*var newDataPublisher: AnyPublisher<[DynamicDisplayType], Never> {
        self.createNewDataPublisher().onMainScheduler()
    }*/

    var endRefreshPublisher: AnyPublisher<Void, Never> {
        self.newDataResultPublisher
            .map { _ in }
            .onMainScheduler()
    }

    private lazy var moreDataResultPublisher: AnyPublisher<[DynamicDisplayType]?, Never> = {
        self.createMoreDataPublisher()
            .share()
            .eraseToAnyPublisher()
    }()

    var moreDataPublisher: AnyPublisher<[DynamicDisplayType], Never> {
        self.moreDataResultPublisher
            .compactMap { $0 }
            .onMainScheduler()
    }

    var endMoreRefreshPublisher: AnyPublisher<Bool, Never> {
        self.moreDataResultPublisher
            .map { _ in kDynamicFileIndex < 5 }
            .merge(with: self.newDataResultPublisher.map { _ in true })
            .onMainScheduler()
    }

    var toastPublisher: AnyPublisher<String, Never> {
        self.newDataResultPublisher
            .compactMap { result -> String? in
                switch result {
                case .success(_):
                    return nil
                case .failure(_):
                    return ">_< 数据丢失了!"
                }
            }
            .merge(with: self.moreDataResultPublisher.compactMap { $0 == nil ? ">_< 数据丢失了!" : nil })
            .onMainScheduler()
    }
}


private extension TextureDemoViewModel {

    func queryNewData() {
        kDynamicFileIndex = 0
        self.refreshSubject.send()
        self.topicSubject.send()
    }

    func createNewDataPublisher() -> AnyPublisher<Result<[DynamicDisplayType], BundleJsonDataError>, Never> {

        let dynamicPublisher = self.refreshSubject
            .map { _ -> String? in
                let idx = kDynamicFileIndex % 2
                kDynamicFileIndex += 1
                return Bundle.main.path(forResource: "xt_dynamic_list_\(idx).json", ofType: nil)
            }
            .flatMap { path -> AnyPublisher<Result<XTListResultModel, BundleJsonDataError>, Never> in
                BundleJsonDataPublisher<XTListResultModel>(filePaht: path)
                    .map { Result<XTListResultModel, BundleJsonDataError>.success($0) }
                    .catch { Just<Result<XTListResultModel, BundleJsonDataError>>(.failure($0)) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()


        let topicPublisher = self.topicSubject
            .map { _ in Bundle.main.path(forResource: "xt_topic_recommend_list.json", ofType: nil) }
            .flatMap { path -> AnyPublisher<Result<TopicListModel, BundleJsonDataError>, Never> in
                BundleJsonDataPublisher<TopicListModel>(filePaht: path)
                    .map { Result<TopicListModel, BundleJsonDataError>.success($0) }
                    .catch { Just<Result<TopicListModel, BundleJsonDataError>>(.failure($0)) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let showPubliser = Publishers.Zip(dynamicPublisher, topicPublisher)
            .map { (dynamicResult, topicResult) -> Result<[DynamicDisplayType], BundleJsonDataError> in
                var resultArray: [DynamicDisplayType] = []
                switch topicResult {
                case .success(let wrappedModel):
                    if let list = wrappedModel.data, !list.isEmpty {
                        resultArray.append(.topicList(list))
                    }
                case .failure(let error):
                    // 无数据不展示
                    print(error)
                }

                switch dynamicResult {
                case .success(let wrappedModel):
                    if let list = wrappedModel.data {
                        resultArray.append(contentsOf: list.map { .dynamic($0) })
                    }
                case .failure(let error):
                    return .failure(error)
                }

                return .success(resultArray)
            }
            .eraseToAnyPublisher()

        return showPubliser
    }

    func createMoreDataPublisher() -> AnyPublisher<[DynamicDisplayType]?, Never> {
        self.moreDataSubject
            .map { _ -> String? in
                // 模拟失败
                let idx = kDynamicFileIndex != 3 ? kDynamicFileIndex % 2 : 2
                kDynamicFileIndex += 1
                let dynamicPath = Bundle.main.path(forResource: "xt_dynamic_list_\(idx).json", ofType: nil)
                return dynamicPath
            }
            .flatMap { path -> AnyPublisher<[DynamicDisplayType]?, Never> in
                BundleJsonDataPublisher<XTListResultModel>(filePaht: path)
                    .map { wrappedModel -> [DynamicDisplayType]? in
                        if let list = wrappedModel.data, !list.isEmpty {
                            let resultArray: [DynamicDisplayType] = list.map { .dynamic($0) }
                            return resultArray
                        }
                        return nil
                    }
                    .catch { _  in
                        Just<[DynamicDisplayType]?>(nil)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}


private extension TextureDemoViewModel {

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
        _ = DynamicNetworkService.topicListRecommend
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
            }
    }
}
