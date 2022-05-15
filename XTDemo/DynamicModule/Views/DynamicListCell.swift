//
/*
* ****************************************************************
*
* 文件名称 : DynamicListCell
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:28 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import UIKit
import Foundation
import Combine


/// cell subview 事件处理
protocol DynamicListCellDelegate: AnyObject {

    func listCell(_ cell: DynamicListCell, selectedView: UIView, selectedImage at: Int, allImages: [String])

    func listCell(_ cell: DynamicListCell, showDiggForMsg: String?)

    // TODO: - 需要点击头像, 分享 的时间传递
}

extension DynamicListCell {

    enum LayoutInfo {
        static let margin = UIEdgeInsets.only(.horizontal, value: 15)
    }

    enum DisplayInfo {
        //static let font:
    }
}

final class DynamicListCell: UITableViewCell {

// MARK: - 属性

    static let reusIdentify: String = "DynamicListCellID"

    internal weak var delegate: DynamicListCellDelegate?

    private let viewModel: DynamicListCellModelType = DynamicListCellModel()
    private var cancellable: Set<AnyCancellable> = []

    private let dataSource = DynamicListCellDataSource()

// MARK: - 生命周期 & override

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("Dr 不支持!")
    }

    override func prepareForReuse() {
        cancellable = []
    }


// MARK: - UI element

    private var dynamicContentView: DynamicListContnetTextView!
    private var testView1: UIView!
    private var testView2: UIView!
}

// MARK: - event handler

extension DynamicListCell {

    func eventListen() {
    }

    func testShow(row: Int) {

        testView1.isHidden = (row % 3 == 1)
        testView2.isHidden = (row % 3 == 2)
        dynamicContentView.attributedText = dataSource.attributedString(at: row)

    }
}

// MARK: - binding viewModel

extension DynamicListCell {

    func bindViewModel() {
    }
}

// MARK: - 设置 UI 布局

private extension DynamicListCell {

    func setupUI() {
        let mainStackView = UIStackView(frame: .zero)
        // vertical: 垂直布局; horizontal: 水平布局;
        mainStackView.axis = .vertical
        // alignment 属性有, fill: 填充; center: 居中;
        // horizontal 则为垂直方向有, top: 顶对齐; bottom: 底对齐;
        // vertical 则为水平方向有, leading: 左对齐; trailing: 右对齐;
        mainStackView.alignment = .fill
        mainStackView.distribution = .equalSpacing
        mainStackView.spacing = 10

        contentView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.insetToSuperView(with: LayoutInfo.margin)

        testView1 = createTestView()
        testView1.backgroundColor = .red
        testView2 = createTestView()
        testView2.backgroundColor = .green
        dynamicContentView = DynamicListContnetTextView(margin: .zero)

        mainStackView.addArrangedSubview(testView1)
        mainStackView.addArrangedSubview(dynamicContentView)
        mainStackView.addArrangedSubview(testView2)
    }

    func createTestView() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .randomWithoutAlpha
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 45)
        ])
        return view
    }
}

