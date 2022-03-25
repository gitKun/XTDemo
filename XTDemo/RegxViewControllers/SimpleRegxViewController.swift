//
/*
* ****************************************************************
*
* 文件名称 : SimpleRegxViewController
* 作   者 : Created by 坤
* 创建时间 : 2022/3/24 7:40 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/24 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit
import SnapKit

fileprivate let testString = #"""
 谁推的夜的命名术，看上瘾了，赔钱![黑脸]. 钱不太到位，[吐舌]工资分两次发[不看]. 你们买零食大礼包吗，买哪家的 多少钱[不失礼貌的微笑],只是不买大礼包，大礼包搭配的不一定都是爱吃的呀[白眼的狗]。一般都是去超市或者便利店或者零食店，或者李佳琦直播间买。比如近俩月入了佳琦推荐的黑枸杞，桂圆干，鱿鱼条，鱼皮花生豆，西梅干，脆皮热狗肠，哈尔滨红肠，满*饱米线，柳州螺蛳粉，藤*鸭舌，腰果，松子，蛋黄酥，鸡蛋酥。然后逛超市会买些巧克力，软糖，罐头，逛零食店会买散装的小包辣条，鸡爪，鸭掌，面筋，麻辣肉，火鸡面啥的。哈哈哈哈哈我不是给佳琦打广告可是真的很实惠啊，而且他叫我美眉诶[泣不成声]
 刚领证，最近一直吵架，离婚能把彩礼，和买房的首付三十多万，房子只写了女方的名字 ，能把钱都拿回来吗？ [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，女方，一直在说分手，不联系，离婚之类的话，而且大晚上吵，凌晨两三点才能睡， 烦的感觉快受不了了，想同意了她说的 离婚，不联系啥的[骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] 领证了，没有办酒席，也没在一[不失礼貌的微笑]起住.[吐舌][吐舌][吐舌][吐舌][70207195222222288819#一句话惹恼程序员#]
"""#


class SimpleRegxViewController: UIViewController {

// MARK: - 成员变量


// MARK: - 生命周期 & override

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeUI()
        eventListen()
        bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

// MARK: - UI 属性

    private let scrollView = UIScrollView(frame: .zero)
    private let infoBGView = UIView(frame: .zero)
    private let infoLabel = UILabel(frame: .zero)
}

// MARK: - 事件处理

extension SimpleRegxViewController {

    func eventListen() {

        let _ = EmojiAttributedProvider.shared
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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

            self.infoLabel.attributedText = attributedStr
        }
        
    }
}

// MARK: - 绑定 viewModel

extension SimpleRegxViewController {

    func bindViewModel() {
    }
}

// MARK: - 布局UI元素

extension SimpleRegxViewController {

    func initializeUI() {
        view.backgroundColor = .white
        navigationItem.title = "简单使用正则"

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.trailing.leading.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            make.bottom.equalToSuperview()
        }

        scrollView.addSubview(infoBGView)
        infoBGView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        infoLabel.numberOfLines = 0
        infoBGView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview()
        }
    }
}

