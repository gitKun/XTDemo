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

protocol DynamicListViewModelInputs {

    func viewDidLoad()
    func refreshDate()
    func moreData(with cursor: String)

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

        self.initializedSubject()
    }

    private func initializedSubject() {
        let loadDataAction = self.loadDataSubject.compactMap { $0 }

        let dynamycNewData = loadDataAction.filter { $0 == "0" }.map { cursor -> DynamicListParam in
            return DynamicListParam(cursor: cursor)
        }.flatMap { param -> Single<XTListResultModel> in
            // request(.list(param: param.toJsonDict())).map(XTListResultModel.self)
            return DynamicNetworkService.list(param: param.toJsonDict()).request().map(XTListResultModel.self)
        }.flatMap { model -> Single<Result<XTListResultModel, Error>> in
            return .just(.success(model))
        }.catch { .just(.failure($0)) }

        let topicListData = topicListSubject.flatMap { _ -> Single<TopicListModel> in
            return DynamicNetworkService.topicListRecommend.memoryCacheIn().request().map(TopicListModel.self)
        }.flatMap { model -> Single<Result<TopicListModel, Error>> in
            return .just(.success(model))
        }.catch {  .just(.failure($0)) }

        Observable.zip(dynamycNewData, topicListData).flatMap { (dynamicWrapped, topicListWrapped) -> Observable<Result<DynamicDisplayModel, Error>> in
            var displayModel = DynamicDisplayModel()
            var showList = [DynamicDisplayType]()

            switch topicListWrapped {
            case .success(let wrapped):
                if let list = wrapped.data, !list.isEmpty {
                    showList.append(.topicList(list))
                    /*(showList.count > 2 ? { showList.insert(.topicList(list), at: 2) } : { showList.append(.topicList(list)) })()*/
                }
            case .failure(let error):
                // FIXED: - 请求或者解析数据失败, 不作任何处理, 界面不展示
                print(error)
            }

            switch dynamicWrapped {
            case .success(let wrapped):
                displayModel = DynamicDisplayModel.init(from: wrapped)
                if let list = wrapped.data {
                    showList.append(contentsOf: list.map { .dynamic($0) })
                }
            case .failure(let error):
                return .just(.failure(error))
            }

            displayModel.updateDisplayModels(from: showList)
            return .just(.success(displayModel))
        }.subscribe(onNext: { [weak self] wrappedRes in
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
        }).disposed(by: self.disposeBag)

        loadDataAction.filter { $0 != "0" }.map { cursor -> DynamicListParam in
            return DynamicListParam(cursor: cursor)
        }.flatMap { param -> Single<XTListResultModel> in
            return DynamicNetworkService.list(param: param.toJsonDict()).request().map(XTListResultModel.self)
        }.flatMap { wrapped -> Observable<DynamicDisplayModel> in
            var displayModel = DynamicDisplayModel.init(from: wrapped)
            if let list = wrapped.data {
                let showList: [DynamicDisplayType] = list.map { .dynamic($0) }
                displayModel.updateDisplayModels(from: showList)
            }
            return .just(displayModel)
        }.subscribe(onNext: { [weak self] model in
            // FIXED: - 数据完整性校验,在 dataSource 中, loadDataSubject 不能保证数据的正确
            // if let cursor = try? self?.loadDataSubject.value(), cursor == "0" { return }
            self?.moreDataSubject.onNext(model)
            self?.hasMoreDataSubject.onNext(model.hasMore)
            // 清空当前请求的状态
            self?.loadDataSubject.onNext(nil)
        }, onError: { error in
            if let error = error as? MoyaError {
                self.handleMoyaError(error, fromNewData: false)
            } else {
                print(error)
            }
        }).disposed(by: self.disposeBag)
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

    // private let startMoreDataSubject = PublishSubject<Void>()
    private let hasMoreDataSubject = BehaviorSubject(value: false)
    private let hiddenMoreDataSubect: BehaviorSubject<Void> = .init(value: ())
    func moreData(with cursor: String) {
        // nil 状态表示 没有在刷新,也没有在加载更多. 可以加载数据
        guard let value = try? loadDataSubject.value() else {
            loadDataSubject.onNext(cursor)
            // startMoreDataSubject.onNext(())
            return
        }

        if value == "0" {
            // 正在刷新, 结束加载更多状态, 不请求数据
            hasMoreDataSubject.onNext(true)
        } else {
            loadDataSubject.onNext(cursor)
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
