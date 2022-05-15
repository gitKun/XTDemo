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
// MARK: - 测试数据

    private var testAttributedStingArray: [NSAttributedString] = []

    func attributedString(at row: Int) -> NSAttributedString {
        return testAttributedStingArray[row % testAttributedStingArray.count]
    }

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

// MARK: - 生命周期

    override init() {
        super.init()

        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        let lineHeight = 20.sizeFromIphone6
        let paragraph = NSMutableParagraphStyle()
        paragraph.maximumLineHeight = lineHeight
        paragraph.minimumLineHeight = lineHeight
        // 首行缩进2字符
        //paragraph.firstLineHeadIndent = font.pointSize * 2
        // 文本两端对齐
        paragraph.alignment = .justified
        let baselineOffset = (lineHeight  - font.lineHeight) / 4
        let attr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.hex(0x101010), .font: font, .paragraphStyle: paragraph, .baselineOffset: baselineOffset]
        self.testAttributedStingArray = [
            .init(string: "macbook pro平常是插着电用呢，还是快没电了再插电呢？", attributes: attr),
            .init(string: "兄弟们，第四次发帖了。新情况，那个女生拒绝和我交往，说她妈妈不同意，我想如何旁敲侧击的如何问出来因为什么不同意，她答应做我朋友了，我该如何升级关系呢，她喜欢比较恐怖的，我还有机会吗，求分析啊，我好笨，看不出来啊", attributes: attr),
            .init(string: "我之前也是 她不让我去 我还没她妈妈的微信 我是在追她的吗 知道她家在哪 我自己去她家敲门的... 然后知道她妹妹要中考了 成绩不太行 主动提出来可以免费帮她补习 然后每周去补习给她妹妹带各种好吃的 然后紧接着是她的爷爷奶奶 补习有空的时候 配他们两老人家多聊天 最后知道丈母娘喜欢喝红酒 再然后就是和她们家所有人打成一片...[奸笑]", attributes: attr),
            .init(string: "裸辞一个月了快，干点喜欢的事，学点新东西，感觉也很充实。 睡得比上班时候早，醒的也很早。自己做饭菜，也很悠闲。那 上班的目的是什么呢，活着是为了生活还是为了工作呢。", attributes: attr),
        ]
    }

    deinit {
        print("DynamicListCellDataSource deinit! ____#")
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
