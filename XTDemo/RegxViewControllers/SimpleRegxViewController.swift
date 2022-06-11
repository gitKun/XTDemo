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


fileprivate let testString = #"""
![黑脸].钱不太到位，[吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰][吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰][不看].  [吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰]，[吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] ，能把钱都拿回来吗？ [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，女方，[吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰]，凌晨两三点才能睡， [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，婚，不联系啥的[骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] 领证了，没有办酒席
 刚领证，最近一直吵架，离婚能把彩礼，和买房的首付三十多万，房子只写了女方的名字 ，能把钱都拿回来吗？ [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，女方，一直在说分手，不联系，离婚之类的话，而且大晚上吵，凌晨两三点才能睡， 烦的感觉快受不了了，想同意了她说的 离婚，不联系啥的[骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] 领证了，没有办酒席，也没在一[不失礼貌的微笑]起住.[吐舌][吐舌][吐舌][吐舌]![黑脸].钱不太到位，[吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰][吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰][不看].  [吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰]，[吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] ，能把钱都拿回来吗？ [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，女方，[吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰]，凌晨两三点才能睡， [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，婚，不联系啥的[骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] 领证了，没有办酒席
 刚领证，最近一直吵架，离婚能把彩礼，和买房的首付三十多万，房子只写了女方的名字 ，能把钱都拿回来吗？ [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，女方，一直在说分手，不联系，离婚之类的话，而且大晚上吵，凌晨两三点才能睡， 烦的感觉快受不了了，想同意了她说的 离婚，不联系啥的[骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] 领证了，没有办酒席，也没在一[不失礼貌的微笑]起住.[吐舌][吐舌][吐舌][吐舌]![黑脸].钱不太到位，[吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰][吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰][不看].  [吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰]，[吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] ，能把钱都拿回来吗？ [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，女方，[吐舌][骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰]，凌晨两三点才能睡， [骷髅][骷髅][骷髅][衰][骷髅][衰] 最近一直吵架，婚，不联系啥的[骷髅][衰][骷髅][衰][衰][骷髅][衰][骷髅][衰] 领证了，没有办酒席
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let attributedString = infoLabel.attributedText else { return }

        print("======= BEGAIN =======")
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        let limitSize = CGSize(width: infoLabel.bounds.width, height: 0xFFFFFF)
        let fitsize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedString.length), nil, limitSize, nil)
        print("计算的 size = \(fitsize), 约束得到的 size = \(infoLabel.bounds.size)")
        print("======= END =======")

        calculateHeight1(for: attributedString, width: infoLabel.bounds.width)
        calculateHeight2(for: attributedString, width: infoLabel.bounds.width)
        calculateHeight3(for: attributedString, width: infoLabel.bounds.width)
    }

    func calculateHeight1(for attributedStirng: NSAttributedString, width: CGFloat) {
        let framesetter = CTFramesetterCreateWithAttributedString(attributedStirng as CFAttributedString)
        let height: CGFloat = 0xFFFFFF
        let drawRact = CGRect(x: 0, y: 0, width: width, height: height)
        let cgPath = CGMutablePath()
        cgPath.addRect(drawRact)
        let textFrame = CTFramesetterCreateFrame(framesetter, .init(location: 0, length: 0), cgPath, nil)
        let lines = CTFrameGetLines(textFrame) as! [CTLine]
        let lineCount = lines.count//CFArrayGetCount(lines)
        var lineOrigins: [CGPoint] = Array(repeating: .zero, count: lineCount)

        CTFrameGetLineOrigins(textFrame, .init(location: 0, length: 0), &lineOrigins)
        //print(lineOrigins)

        var heightValue: CGFloat = 0

        /******************
         * 最后一行原点y坐标加最后一行下行行高跟行距
         ******************/
        heightValue = 0;
        let line_y = lineOrigins[lineCount - 1].y //最后一行line的原点y坐标
        var lastAscent: CGFloat = 0 //上行行高
        var lastDescent: CGFloat = 0;//下行行高
        var lastLeading: CGFloat = 0;//行距
        let lastLine = lines[lineCount - 1]
        CTLineGetTypographicBounds(lastLine, &lastAscent, &lastDescent, &lastLeading);
        // height - line_y为除去最后一行的字符原点以下的高度，descent + leading为最后一行不包括上行行高的字符高度
        heightValue = height - line_y + abs(lastDescent) + lastLeading
        heightValue = ceil(heightValue)

        print(ceil(heightValue))
    }

    func calculateHeight2(for attributedStirng: NSAttributedString, width: CGFloat) {
        let framesetter = CTFramesetterCreateWithAttributedString(attributedStirng as CFAttributedString)
        var rangeToSize = CFRangeMake(0, attributedStirng.length)

        let height: CGFloat = 0xFFFFFF
        let drawRact = CGRect(x: 0, y: 0, width: width, height: height)
        let cgPath = CGMutablePath()
        cgPath.addRect(drawRact)
        let textFrame = CTFramesetterCreateFrame(framesetter, .init(location: 0, length: 0), cgPath, nil)
        let lines = CTFrameGetLines(textFrame) as! [CTLine]

        if let lastVisibleLine = lines.last {
            let rangeToLayout = CTLineGetStringRange(lastVisibleLine)
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length)
        }

        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, nil, drawRact.size, nil)
        print(ceil(suggestedSize.height))
    }

    func calculateHeight3(for attributedStirng: NSAttributedString, width: CGFloat) {
        let rect = attributedStirng.boundingRect(with: CGSize(width: width, height: 0xFFFFFF), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        print(rect)
    }

// MARK: - UI 属性

    private let scrollView = UIScrollView(frame: .zero)
    private let infoBGView = UIView(frame: .zero)
    private let infoLabel = UILabel(frame: .zero)
}

// MARK: - 事件处理

extension SimpleRegxViewController {

    func eventListen() {

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

        self.infoLabel.attributedText = attributedStr
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

        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(infoBGView)
        infoBGView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoBGView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            infoBGView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            infoBGView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            infoBGView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            infoBGView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])

        infoLabel.numberOfLines = 0
        infoBGView.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: infoBGView.leadingAnchor, constant: 15),
            infoLabel.trailingAnchor.constraint(equalTo: infoBGView.trailingAnchor, constant: -15),
            infoLabel.topAnchor.constraint(equalTo: infoBGView.topAnchor, constant: 8),
            infoLabel.bottomAnchor.constraint(equalTo: infoBGView.bottomAnchor, constant: 0)
        ])
    }
}

