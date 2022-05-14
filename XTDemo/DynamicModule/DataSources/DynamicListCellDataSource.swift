//
/*
* ****************************************************************
*
* 文件名称 : DynamicListCellDataSource
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:30 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit


final class DynamicListCellDataSource: NSObject, UICollectionViewDataSource {

// MARK: - 属性

    private var model: DynamicListModel!
    private var imageArray: [String] = []

    var imageCount: Int {
        return imageArray.count
    }

    var allImages: [String] {
        return imageArray
    }

    var topic: Topic? {
        if let topic = model.topic, let topicId = topic.topicId, topicId != "0", !(topic.title ?? "").isEmpty {
            return topic
        }

        return nil
    }

    var diggUser: [AuthorUserInfo] {
        guard let users = model.diggUser else { return [] }

        return users
    }

    var recommendId: String? {
        return model.msgId
    }

    var diggCount: Int {
        return model.msgInfo?.diggCount ?? 0
    }

// MARK: - 事件处理

    func configure(with model: DynamicListModel) {
        self.model = model

        imageArray = model.wrappedPictureList
    }

    func diggRecomment(with user: AuthorUserInfo) {
        model.appendDigger(user)
        model.diggdynamic()
    }

    func unDiggRecomment() {
       _ = model.popLastDigger()
        model.unDiggdynamic()
    }

// MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell.init(frame: .zero)
        // TODO: - 设置 cell
    }
}
