//
/*
* ****************************************************************
*
* 文件名称 : ASDK+XT_Ext
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:59 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import AsyncDisplayKit


extension ASImageNode: KingfisherCompatible {}

public extension KingfisherWrapper where Base: ASImageNode {

    func setImage(
        with source: Resource?,
        placeholder: UIImage? = nil,
        failureImage: UIImage? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil)
    {
        guard let source = source else {
            self.base.image = placeholder ?? failureImage
            return
        }

        KingfisherManager.shared.retrieveImage(with: source, options: options, progressBlock: progressBlock, downloadTaskUpdated: nil) { result in
            switch result {
            case .success(let retrieveResult):
                self.base.image = retrieveResult.image
            case .failure(_):
                self.base.image = failureImage ?? placeholder
            }
        }
    }

}

extension Reactive where Base: ASTextNode {
    
    var attributeText: Binder<NSAttributedString?> {
        return Binder(base) { (b, text) in
            b.attributedText = text
        }
    }
}

extension Reactive where Base: ASButtonNode {
    public var tap: ControlEvent<Void> {
        controlEvent(.touchUpInside)
    }
}

extension Reactive where Base: ASControlNode {

    public func controlEvent(_ controlEvents: ASControlNodeEvent) -> ControlEvent<()> {
        let source: Observable<Void> = Observable.create { [weak control = self.base] observer in
                MainScheduler.ensureRunningOnMainThread()

                guard let control = control else {
                    observer.on(.completed)
                    return Disposables.create()
                }

            let controlTarget = ASControlTarget(controlNode: control, eventType: controlEvents) { _ in
                    observer.on(.next(()))
                }

                return Disposables.create(with: controlTarget.dispose)
            }
            .take(until: deallocated)

        return ControlEvent(events: source)
    }

    public var isEnabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = value
        }
    }

    public var isSelected: Binder<Bool> {
        return Binder(self.base) { control, selected in
            control.isSelected = selected
        }
    }

    public func asEvent(_ type: ASControlNodeEvent) -> ControlEvent<Void> {
        let source = Observable<Void>.create { [weak control = self.base] observer in
            MainScheduler.ensureExecutingOnScheduler()

            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }

            let observer = ASControlTarget(controlNode: control, eventType: type) { control in
                observer.on(.next(()))
            }

            return observer
        }.take(until: deallocated)

        return ControlEvent(events: source)
    }

    public func asGesture(_ gestureRecognizer: UIGestureRecognizer) -> ControlEvent<UIGestureRecognizer> {
        let source = Observable<UIGestureRecognizer>.create { [weak control = self.base] observer in
            MainScheduler.ensureExecutingOnScheduler()

            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }

            let observer = ASGestureTarget.init(control, gestureRecognizer) { recognizer in
                observer.on(.next(recognizer))
            }

            return observer
        }.take(until: deallocated)

        return ControlEvent(events: source)
    }
}



final fileprivate class ASControlTarget<Control: ASControlNode>: _RXKVOObserver, Disposable {

    typealias Callback = (Control) -> Void

    let selector = #selector(eventHandler(_:))

    weak var controlNode: Control?
    var callback: Callback?

    init(controlNode: Control, eventType: ASControlNodeEvent, callback: @escaping Callback) {
        super.init()

        self.controlNode = controlNode
        self.callback = callback

        controlNode.addTarget(self, action: selector, forControlEvents: eventType)

        let method = self.method(for: selector)
        if method == nil {
            fatalError("Can't find method")
        }
    }

    @objc func eventHandler(_ sender: UIGestureRecognizer) {
        if let callback = self.callback, let controlNode = self.controlNode {
            callback(controlNode)
        }
    }

    override func dispose() {
        super.dispose()
        self.controlNode?.removeTarget(self, action: selector, forControlEvents: .allEvents)
        self.callback = nil
    }
}

final fileprivate class ASGestureTarget<Control: ASControlNode>: _RXKVOObserver, Disposable {

    typealias Callback = (UIGestureRecognizer) -> Void

    weak var controlNode: Control?
    var callback: Callback?
    let selector = #selector(eventHandler(_:))
    var gestureRecognizer: UIGestureRecognizer?

    init(_ controlNode: Control, _ gestureRecognizer: UIGestureRecognizer, callback: @escaping Callback) {
        super.init()

        self.controlNode = controlNode
        self.callback = callback
        self.gestureRecognizer = gestureRecognizer

        gestureRecognizer.addTarget(self, action: selector)
        controlNode.view.addGestureRecognizer(gestureRecognizer)

        let method = self.method(for: selector)
        if method == nil {
            fatalError("Can't find method")
        }
    }

    @objc func eventHandler(_ sender: UIGestureRecognizer) {
        if let callback = self.callback, let gestureRecognizer = self.gestureRecognizer {
            callback(gestureRecognizer)
        }
    }

    override func dispose() {
        super.dispose()
        self.gestureRecognizer?.removeTarget(self, action: self.selector)
        self.callback = nil
    }
}
