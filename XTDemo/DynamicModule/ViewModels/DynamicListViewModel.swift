//
/*
* ****************************************************************
*
* 文件名称 : DynamicListViewModel
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:24 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import RxSwift
import Moya


//fileprivate enum DynamicListError: Error {
//
//    /// 无网络
//    case reachability
//
//    /// 服务器返回空数据
//    case dataEmpty
//
//    /// 人为创建的的空数据
//    case ignoreData
//}

protocol DynamicListViewModelInputs {

    func viewDidLoad()
    func refreshDate()
    func moreData(with cursor: String, needHot: Bool)

    // FIXED: - 以下 view 层接口需要根据产品的逻辑而定. 例如: 是否要处理一部分埋点之类的额外操作
    /// 查看详情
    func showDetail()

    /// 查看点赞用户
    func diggUserClick()
}

protocol DynamicListViewModelOutputs {

    //var willRefreshData: Observable<Void> { get }

    var refreshData: Observable<DynamicDisplayModel> { get }
    var moreData: Observable<DynamicDisplayModel> { get }
    var endRefresh: Observable<Void> { get }
    var hasMoreData: Observable<Bool> { get }
    var showError: Observable<String> { get }
}

protocol DynamicListViewModelType {
    var input: DynamicListViewModelInputs { get }
    var output: DynamicListViewModelOutputs { get }
}

final class DynamicListViewModel: DynamicListViewModelType, DynamicListViewModelInputs, DynamicListViewModelOutputs {

    var input: DynamicListViewModelInputs { self }

    var output: DynamicListViewModelOutputs { self }

    private let disposeBag = DisposeBag()

    init() {
        self.refreshData = self.refreshDataSubject.asObserver()
        self.moreData = self.moreDataSubject.asObserver()
        self.endRefresh = self.endRefreshDataSubject.asObserver()
        self.hasMoreData = self.hasMoreDataSubject.asObserver()
        self.showError = self.loadDataErrorSubject.asObserver()

        self.initializedDataSubject()
    }

    private func initializedDataSubject() {
        let loadDataAction = loadDataSubject.compactMap { $0 }

        initializedNewDateSubject(with: loadDataAction)
        initializedMoreDataSubject(with: loadDataAction)
    }

    private func initializedNewDateSubject(with loadDataAction: Observable<String>) {
        let dynamycData = loadDataAction.filter { $0 == "0" }.map { cursor -> DynamicListParam in
            DynamicListParam(cursor: cursor)
        }.flatMap { param -> Observable<Result<XTListResultModel, Error>> in
            let result = DynamicNetworkService.list(param: param.toJsonDict())
                .request()
                .map(XTListResultModel.self)
                .flatMap{ model -> Single<Result<XTListResultModel, Error>> in
                    return .just(.success(model))
                } .catch { error in
                    return .just(.failure(error))
                }

            return result.asObservable()
        }

        let topicListData = topicListSubject.flatMap { _ -> Observable<Result<TopicListModel, Error>> in
            let result = DynamicNetworkService.topicListRecommend
                .memoryCacheIn()
                .request()
                .map(TopicListModel.self)
                .flatMap { model -> Single<Result<TopicListModel, Error>> in
                    .just(.success(model))
                }.catch {
                    .just(.failure($0))
                }

            return result.asObservable()
        }

        let newDataSubject = Observable.zip(dynamycData, topicListData).map { (dynamicWrapped, topicListWrapped) -> Result<DynamicDisplayModel, Error> in
            var displayModel = DynamicDisplayModel()

            switch dynamicWrapped {
            case .success(let wrapped):
                displayModel = DynamicDisplayModel.init(from: wrapped)
            case .failure(let error):
                return .failure(error)
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

            return .success(displayModel)
        }

        newDataSubject.subscribe(onNext: { [weak self] wrappedRes in
            switch wrappedRes {
            case .success(let model):
                self?.refreshDataSubject.onNext(model)
                self?.endRefreshDataSubject.onNext(())
                // 清空当前请求的状态
                self?.loadDataSubject.onNext(nil)
            case .failure(let error):
                if let error = error as? MoyaError {
                    self?.handleMoyaError(error, fromNewData: true)
                } else {
                    print(error)
                }
            }
        }).disposed(by: disposeBag)
    }

    private func initializedMoreDataSubject(with loadDataAction: Observable<String>) {
        let dynamycData = loadDataAction.filter { $0 != "0" }.map { cursor -> DynamicListParam in
            DynamicListParam(cursor: cursor)
        }.flatMap { param -> Observable<Result<XTListResultModel, Error>> in
            let result = DynamicNetworkService.list(param: param.toJsonDict())
                .request()
                .map(XTListResultModel.self)
                .map { model -> Result<XTListResultModel, Error> in
                        .success(model)
                }.catch { .just(.failure($0)) }
            
            return result.asObservable()
        }

        let hotData = needHotDynamicSubject.flatMap { needSend -> Observable<Result<XTListResultModel, Error>> in
            if needSend {
                let param = DynamicListParam.hotDymamicParam
                let result = DynamicNetworkService.hot(param: param.toJsonDict())
                    .memoryCacheIn()
                    .request()
                    .map(XTListResultModel.self)
                    .map { model -> Result<XTListResultModel, Error> in
                        .success(model)
                    }.catch { .just(.failure($0)) }

                return result.asObservable()
            } else {
                return .just(.failure(MoyaError.requestMapping("xxxx")))
            }
       }

        let moreData = Observable.zip(dynamycData, hotData).map { listResult, hotResult -> Result<DynamicDisplayModel, Error> in

            var displayModel = DynamicDisplayModel()
            switch listResult {
            case .success(let wrapped):
                displayModel = DynamicDisplayModel.init(from: wrapped)
            case .failure(let error):
                return .failure(error)
            }

            switch hotResult {
            case .success(let wrapped):
                if let list = wrapped.data, !list.isEmpty {
                    var displayList = displayModel.displayModels
                    (displayList.count > 2 ? { displayList.insert(.hotList(list), at: 2) } : { displayList.append(.hotList(list)) } )()
                    displayModel.displayModels = displayList
                }
            case .failure(_):
                // FIXED: - 不作任何事情
                break
            }

            return .success(displayModel)
        }

        moreData.subscribe(onNext: { [weak self] result in
            switch result {
            case .success(let model):
                // FIXED: - 数据完整性校验,在 dataSource 中, loadDataSubject 不能保证数据的正确
                // if let cursor = try? self?.loadDataSubject.value(), cursor == "0" { return }
                self?.moreDataSubject.onNext(model)
                self?.hasMoreDataSubject.onNext(model.hasMore)
                // 清空当前请求的状态
                self?.loadDataSubject.onNext(nil)
            case .failure(let error):
                if let error = error as? MoyaError {
                    self?.handleMoyaError(error, fromNewData: false)
                } else {
                    print(error)
                }
            }
        }).disposed(by: disposeBag)
    }

    // 增加数据请求
    private let topicListSubject = PublishSubject<Void>()
    private let loadDataSubject: BehaviorSubject<String?> = BehaviorSubject(value: nil)
    func viewDidLoad() {
        // 进入界面就要刷新数据
        loadFirstPageData()
    }

    // private let startRefreshDataSubject = PublishSubject<Void>()
    private let endRefreshDataSubject = PublishSubject<Void>()
    func refreshDate() {
        // nil 状态表示 没有在刷新,也没有在加载更多. 可以刷新数据
        guard let value = try? loadDataSubject.value() else {
            loadFirstPageData()
            // startRefreshDataSubject.onNext(())
            return
        }

        if value == "0" {
            // 正在刷新数据, 不做网络请求的操作
        } else {
            // 正在加载更多数据, 结束加载更多的状态, 请求的数据不做使用
            hasMoreDataSubject.onNext(true)
            loadFirstPageData()
        }
    }

    private let hasMoreDataSubject = BehaviorSubject(value: false)
    private let hiddenMoreDataSubect: BehaviorSubject<Void> = .init(value: ())
    private let needHotDynamicSubject = PublishSubject<Bool>()
    func moreData(with cursor: String, needHot: Bool) {
        // nil 状态表示 没有在刷新,也没有在加载更多. 可以加载数据
        guard let value = try? loadDataSubject.value() else {
            loadDataSubject.onNext(cursor)
            needHotDynamicSubject.onNext(needHot)
            return
        }

        if value == "0" {
            // 正在刷新, 结束加载更多状态, 不请求数据
            hasMoreDataSubject.onNext(true)
        } else {
            loadDataSubject.onNext(cursor)
            needHotDynamicSubject.onNext(needHot)
        }
    }

    // FIXED: - 发出对应流, 处理额外事件

    func showDetail() {
    }

    func diggUserClick() {
    }

    private let refreshDataSubject = PublishSubject<DynamicDisplayModel>()
    let refreshData: Observable<DynamicDisplayModel>

    private let moreDataSubject = PublishSubject<DynamicDisplayModel>()
    let moreData: Observable<DynamicDisplayModel>

    private let loadDataErrorSubject = PublishSubject<String>()
    let showError: Observable<String>

    let endRefresh: Observable<Void>
    let hasMoreData: Observable<Bool>
}

// MARK: - 数据处理

fileprivate extension DynamicListViewModel {

    func loadFirstPageData() {
        topicListSubject.onNext(())
        loadDataSubject.onNext("0")
    }

    func handleMoyaError(_ error: MoyaError, fromNewData: Bool) {
        // 清空请求的状态
        defer { loadDataSubject.onNext(nil) }

        var errorMsg = ">_< 数据丢失了,请稍后再试."

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
            // fatalError("找服务端小哥吧")
            //
            break
        case .statusCode(_):
            // FIXME: - 处理 301, 503
            break
        case .underlying(let error, _):
            errorMsg = (error as NSError).localizedDescription
        case .requestMapping(_):
            // fatalError("这里只能出现在debug阶段!")
            break
        case .parameterEncoding(_):
            // fatalError("这里只能出现在debug阶段!")
            break
        }

        endRefreshDataSubject.onNext(())
        hasMoreDataSubject.onNext(true)
        loadDataErrorSubject.onNext(errorMsg)
    }

}
