//
/*
* ****************************************************************
*
* 文件名称 : DynamicListContnetTextView
* 作   者 : Created by 坤
* 创建时间 : 2022/5/15 13:42
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/5/15 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit


final class DynamicListContnetTextView: UIView {

// MARK: - 属性

    /// 边距, 影响的是整体的布局
    var margin: UIEdgeInsets = .zero

    /// 属性字符串
    var attributedText: NSAttributedString? {
        didSet {
            self.infoLabel.attributedText = attributedText
            self.setNeedsLayout()
        }
    }

// MAKR: - 生命周期 & override

    init(margin: UIEdgeInsets) {
        self.margin = margin
        super.init(frame: .zero)

        setupUI()
    }

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setupUI()
//    }

    required init?(coder: NSCoder) {
        fatalError("Dr 不支持!")
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if self.infoLabel.bounds.width.isLessThanOrEqualTo(.zero) {
//            self.invalidateIntrinsicContentSize()
//        }
//    }

    /// 约束的自定义布局大小
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: bounds.width, height: 48)
//    }

// MARK: - UI element

    private var infoLabel: UILabel!
    private var moreButton: UIButton!
}


// MARK: - 初始化 UI

private extension DynamicListContnetTextView {

    func setupUI() {
        infoLabel = UILabel(frame: .zero)
        infoLabel.numberOfLines = 0
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: margin.top),
            infoLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: margin.left),
            infoLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin.right)
        ])

        moreButton = UIButton(type: .custom)
        moreButton.setTitle("展开", for: .normal)
        moreButton.setTitle("收起", for: .selected)
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        moreButton.setTitleColor(.XiTu.hotShortZan, for: .normal)
        moreButton.contentEdgeInsets = .init(top: 3, left: 0, bottom: 3, right: 3)
        addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.sizeToFit()
        NSLayoutConstraint.activate([
            moreButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 5),
            moreButton.leftAnchor.constraint(equalTo: leftAnchor, constant: margin.left),
            moreButton.heightAnchor.constraint(equalToConstant: moreButton.bounds.height),
            moreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin.bottom)
        ])

    }
}
