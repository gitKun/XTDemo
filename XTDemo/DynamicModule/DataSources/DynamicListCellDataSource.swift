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

fileprivate let testString = #"""
 谁推的夜的命名术，看上瘾了，赔钱![黑脸]. 钱不太到位，[吐舌]工资分两次发[不看]. 你们买零食大礼包吗，买哪家的 多少钱[不失礼貌的微笑],只是不买大礼包，大礼包搭配的不一定都是爱吃的呀[白眼的狗]。一般都是去超市或者便利店或者零食店，或者李佳琦直播间买。比如近俩月入了佳琦推荐的黑枸杞，桂圆干，鱿鱼条，鱼皮花生豆，西梅干，脆皮热狗肠，哈尔滨红肠，满*饱米线，柳州螺蛳粉，藤*鸭舌，腰果，松子，蛋黄酥，鸡蛋酥。然后逛超市会买些巧克力，软糖，罐头，逛零食店会买散装的小包辣条，鸡爪，鸭掌，面筋，麻辣肉，火鸡面啥的。哈哈哈哈哈我不是给佳琦打广告可是真的很实惠啊，而且他叫我美眉诶[泣不成声]
 刚领证，最近一直吵架，离婚能把彩礼，和买房的首付三十多万，房子只写了女方的名字 ，能把钱都拿回来吗？ [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，女方，一直在说分手，不联系，离婚之类的话，而且大晚上吵，凌晨两三点才能睡， 烦的感觉快受不了了，想同意了她说的 离婚，不联系啥的[骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] 领证了，没有办酒席，也没在一[不失礼貌的微笑]起住.[吐舌][吐舌][吐舌][吐舌][70207195222222288819#一句话惹恼程序员#]
"""#

final class DynamicListCellDataSource: NSObject, UICollectionViewDataSource {
// MARK: - 测试数据

    private var testAttributedStingArray: [NSAttributedString] = []

    func attributedString(at row: Int) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 15, weight: .regular)
        let lineHeight: CGFloat = 21
        let paragraph = NSMutableParagraphStyle()
        paragraph.maximumLineHeight = lineHeight
        paragraph.minimumLineHeight = lineHeight
        paragraph.alignment = .justified

        let baselineOffset = (lineHeight  - font.lineHeight) / 4

        let attr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.XiTu.shortContent,
            .font: font,
            .paragraphStyle: paragraph,
            .baselineOffset: baselineOffset
        ]
        let attributedStr = EmojiAttributedProvider.shared.generateEmojiAttributedString(from: testString, attributed: attr, imageHeihg: font.lineHeight)
        //let attributedStr = NSAttributedString(string: testString, attributes: attr)
        return attributedStr
        //return testAttributedStingArray[row % testAttributedStingArray.count]
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
