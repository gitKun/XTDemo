//
/*
* ****************************************************************
*
* 文件名称 : DynamicListViewModel
* 作   者 : Created by 坤
* 创建时间 : 2022/4/8 20:26
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/8 初始版本
*
* ****************************************************************
*/

import Foundation
import Combine
import Moya

protocol DynamicListViewModelInputs {

    func viewDidLoad()
    func refreshDate()
    func moreData(with cursor: String, needHot: Bool)
}

protocol DynamicListViewModelOutputs {

    // TODO: - 想要使用 Deferred + Future 实现 RxSwift 的 Single.
    var newData: AnyPublisher<DynamicDisplayModel, Never> { get }
    var moreData: AnyPublisher<DynamicDisplayModel, Never> { get }
    var endRefresh: AnyPublisher<Void, Never> { get }
    var hasMoreData: AnyPublisher<Bool, Never> { get }
    var showError: AnyPublisher<String, Never> { get }
}

protocol DynamicListViewModelType {
    var input: DynamicListViewModelInputs { get }
    var output: DynamicListViewModelOutputs { get }
}

final class DynamicListViewModel: DynamicListViewModelType, DynamicListViewModelInputs, DynamicListViewModelOutputs {

    var input: DynamicListViewModelInputs { self }
    var output: DynamicListViewModelOutputs { self }

    init() {
        self.endRefresh = self.endRefreshSubject.receive(on: RunLoop.main).eraseToAnyPublisher()
        self.hasMoreData = self.hasMoreDataSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        self.showError = self.showErrorSubject.receive(on: RunLoop.main).eraseToAnyPublisher()
    }

// MARK: - output

    fileprivate let endRefreshSubject = PassthroughSubject<Void, Never>()
    let endRefresh: AnyPublisher<Void, Never>

    private let hasMoreDataSubject = PassthroughSubject<Bool, Never>()
    let hasMoreData: AnyPublisher<Bool, Never>

    private let showErrorSubject = PassthroughSubject<String, Never>()
    let showError: AnyPublisher<String, Never>

// MARK: - input

    private lazy var newDataSubject: AnyPublisher<DynamicDisplayModel, Never> = {
        let subject = self.createNewDataSubject()
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        return subject
    }()
    var newData: AnyPublisher<DynamicDisplayModel, Never> {
        return self.newDataSubject
    }

    private lazy var moreDataSubject: AnyPublisher<DynamicDisplayModel, Never> = {
        return self.createMoreDataSubject()
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }()
    var moreData: AnyPublisher<DynamicDisplayModel, Never> {
        return self.moreDataSubject
    }

    private let loadDataSubject: CurrentValueSubject<String?, Never> = CurrentValueSubject(nil)
    private let topicDataSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    func viewDidLoad() {
        loadFirstPageData()
    }

    private let topicListSubject = PassthroughSubject<Void, Never>()
    func refreshDate() {
        guard let value = loadDataSubject.value else {
            loadFirstPageData()
            return
        }

        // FIXME: - 外部代码保证的情况下, 这里永远不会(应该)执行
        if value != "0" {
            hasMoreDataSubject.send(true)
            loadFirstPageData()
        }
    }

    func moreData(with cursor: String, needHot: Bool) {
        guard let value = loadDataSubject.value else {
            loadDataSubject.send(cursor)
            return
        }

        // FIXME: - 同理这里永远不应该执行
        if value != "0" {
            loadDataSubject.send(cursor)
        } else {
            // 结束 load more 操作
            hasMoreDataSubject.send(true)
        }
    }
}


fileprivate extension DynamicListViewModel {

    func loadFirstPageData() {
        loadDataSubject.send("0")
        topicDataSubject.send(())
    }

    func createNewDataSubject() -> AnyPublisher<DynamicDisplayModel?, Never> {

        let dynamicSubject = loadDataSubject.compactMap { $0 }
            .filter { $0 == "0" }
            .map { DynamicListParam(cursor: $0) }
            .flatMap { param -> AnyPublisher<Result<XTListResultModel, Error>, Never> in
                DynamicNetworkService.list(param: param.toJsonDict())
                    .request()
                    .map(XTListResultModel.self)
                    .map { model -> Result<XTListResultModel, Error> in
                        return .success(model)
                    }
                    .catch { Just(.failure($0)) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let topicSubject = topicDataSubject.flatMap { _ -> AnyPublisher<Result<TopicListModel, Error>, Never> in
            DynamicNetworkService.topicListRecommend
                .memoryCacheIn()
                .request()
                .map(TopicListModel.self)
                .map { Result<TopicListModel, Error>.success($0) }
                .catch { Just(.failure($0)) }
                .eraseToAnyPublisher()
        }

        let newData = Publishers.Zip(dynamicSubject, topicSubject).map { [weak self] (dynamicWrapped, topicListWrapped) -> DynamicDisplayModel? in
            var displayModel = DynamicDisplayModel()

            switch dynamicWrapped {
            case .success(let wrapped):
                displayModel = DynamicDisplayModel.init(from: wrapped)
            case .failure(let error):
                if let error = error as? MoyaError {
                    self?.handleMoyaError(error, fromNewData: true)
                } else {
                    print(error)
                }
                return nil
            }

            switch topicListWrapped {
            case .success(let wrapped):
                if let list = wrapped.data, !list.isEmpty {
                    displayModel.displayModels.insert(.topicList(list), at: 0)
                }
            case .failure(let error):
                // FIXED: - 请求或者解析数据失败, 不作任何处理, 界面不展示
                print(error)
            }

            defer {
                self?.endRefreshSubject.send(())
                // 清空当前请求的状态
                self?.loadDataSubject.send(nil)
            }

            return displayModel
        }
        .eraseToAnyPublisher()

        return newData
    }

    func createMoreDataSubject() -> AnyPublisher<DynamicDisplayModel?, Never> {
        let dynamicSubject = loadDataSubject.compactMap { $0 }
            .filter { $0 != "0" }
            .map { DynamicListParam(cursor: $0) }
            .flatMap { param -> AnyPublisher<Result<XTListResultModel, Error>, Never> in
                DynamicNetworkService.list(param: param.toJsonDict())
                    .request()
                    .map(XTListResultModel.self)
                    .map { model -> Result<XTListResultModel, Error> in
                        return .success(model)
                    }
                    .catch { Just(.failure($0)).eraseToAnyPublisher() }
                    .eraseToAnyPublisher()
            }.map { [weak self] dynamicResult -> DynamicDisplayModel? in
                switch dynamicResult {
                case .success(let wrapped):
                    let displayModel = DynamicDisplayModel.init(from: wrapped)
                    defer {
                        self?.hasMoreDataSubject.send(displayModel.hasMore)
                        self?.loadDataSubject.send(nil)
                    }
                    return displayModel
                case .failure(let error):
                    if let error = error as? MoyaError {
                        self?.handleMoyaError(error, fromNewData: false)
                    } else {
                        print(error)
                    }
                    return nil
                }
            }
            .eraseToAnyPublisher()

        return dynamicSubject
    }

    func handleMoyaError(_ error: MoyaError, fromNewData: Bool) {
        // 清空请求的状态
        defer { loadDataSubject.send(nil) }

        let errorMsg = ">_< 数据丢失了,请稍后再试."

        switch error {
        case .imageMapping(_):
            break
        case .jsonMapping(_):
            break
        case .stringMapping(_):
            break
        case .objectMapping(let error, _):
            print(error)
            break
        case .encodableMapping(_ ):
            break
        case .statusCode(_):
            // FIXME: - 处理 301, 503
            break
        case .underlying(let error, _):
            //errorMsg = (error as NSError).localizedDescription
            print(error)
            if let afError = error.asAFError, case let .sessionTaskFailed(error: sError) = afError {
                print(sError)
            }
            break
        case .requestMapping(_):
            // fatalError("这里只能出现在debug阶段!")
            break
        case .parameterEncoding(_):
            // fatalError("这里只能出现在debug阶段!")
            break
        }

        endRefreshSubject.send(())
        hasMoreDataSubject.send(true)
        showErrorSubject.send(errorMsg)
    }
}
