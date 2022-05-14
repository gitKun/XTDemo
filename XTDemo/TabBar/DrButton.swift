//
/*
* ****************************************************************
*
* 文件名称 : DrButton
* 作   者 : Created by 坤
* 创建时间 : 2022/3/12 3:28 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 :  从 QMUIButton 抄来的!!!
* 修改历史 : 2022/3/12 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit


public enum DrButtonImagePosition {
    case top, left, bottom, right
}

open class DrButton: UIButton {

// MARK: - 属性

    /// 让按钮的文字颜色自动跟随tintColor调整（系统默认titleColor是不跟随的）
    open var adjustsTitleTintColorAutomatically: Bool = false {
        didSet { updateTitleColorIfNeeded() }
    }

    /// 让按钮的图片颜色自动跟随tintColor调整（系统默认image是需要更改renderingMode才可以达到这种效果）
    open var adjustsImageTintColorAutomatically: Bool = false {
        didSet {
            if oldValue != adjustsImageTintColorAutomatically {
                updateImageRenderingModeIfNeeded()
            }
        }
    }

    /**
     * 等价于 adjustsTitleTintColorAutomatically = YES & adjustsImageTintColorAutomatically = YES & tintColor = xxx
     *
     *  不支持传 nil
     */
    open var tintColorAdjustsTitleAndImage: UIColor? = nil {
        didSet {
            if let color = tintColorAdjustsTitleAndImage {
                tintColor = color
                adjustsTitleTintColorAutomatically = true
                adjustsImageTintColorAutomatically = true
            }
        }
    }

    /// 是否自动调整highlighted时的按钮样式，默认为YES。
    ///
    /// 当值为YES时，按钮highlighted时会改变自身的alpha属性为 ButtonHighlightedAlpha
    open var adjustsButtonWhenHighlighted: Bool = true

    /// 是否自动调整disabled时的按钮样式，默认为YES。
    ///
    /// 当值为YES时，按钮disabled时会改变自身的alpha属性为 ButtonDisabledAlpha
    open var adjustsButtonWhenDisabled: Bool = true

    /// 设置按钮点击时的背景色，默认为nil。
    ///
    /// 不支持带透明度的背景颜色。当设置highlightedBackgroundColor时，会强制把adjustsButtonWhenHighlighted设为NO，避免两者效果冲突。
    open var highlightedBackgroundColor: UIColor? = nil {
        didSet {
            if let _ = highlightedBackgroundColor {
                // 只要开启了highlightedBackgroundColor，就默认不需要alpha的高亮
                self.adjustsButtonWhenHighlighted = false
            }
        }
    }

    /// 设置按钮点击时的边框颜色，默认为nil。
    ///
    /// 当设置highlightedBorderColor时，会强制把adjustsButtonWhenHighlighted设为NO，避免两者效果冲突。
    open var highlightedBorderColor: UIColor? = nil {
        didSet {
            if let _ = highlightedBorderColor {
                // 只要开启了highlightedBorderColor，就默认不需要alpha的高亮
                self.adjustsButtonWhenHighlighted = false
            }
        }
    }

    /// 设置按钮里图标和文字的相对位置
    ///
    /// 可配合imageEdgeInsets、titleEdgeInsets、contentHorizontalAlignment、contentVerticalAlignment使用
    open var imagePosition: DrButtonImagePosition = .left {
        didSet {
            setNeedsLayout()
        }
    }

    /// 设置按钮里图标和文字之间的间隔，会自动响应 imagePosition 的变化而变化，默认为0
    ///
    /// 系统默认实现需要同时设置 titleEdgeInsets 和 imageEdgeInsets，同时还需考虑 contentEdgeInsets 的增加（否则不会影响布局，可能会让图标或文字溢出或挤压），使用该属性可以避免以上情况。
    ///
    /// 会与 imageEdgeInsets、 titleEdgeInsets、 contentEdgeInsets 共同作用。
    open var spacingBetweenImageAndTitle: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 默认为 0
    // open var cornerRadius: CGFloat = 0

    private lazy var highlightedBackgroundLayer: CALayer = {
        let layer = CALayer()
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()

    private var originBorderColor: UIColor!

// MARK: - 声明周期 & override

    public override init(frame: CGRect) {

        super.init(frame: frame)
        // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
        self.contentEdgeInsets = UIEdgeInsets(top: .leastNormalMagnitude, left: 0, bottom: .leastNormalMagnitude, right: 0)

        didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue

            if newValue, originBorderColor == nil {
                // 手指按在按钮上会不断触发setHighlighted:，所以这里做了保护，设置过一次就不用再设置了
                originBorderColor = UIColor.init(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
            }

            // 渲染背景色
            if (highlightedBackgroundColor != nil) || (highlightedBorderColor != nil) {
                adjustsButtonHighlighted()
            }

            // 如果此时是disabled，则disabled的样式优先
            guard self.isEnabled else { return }

            // 自定义highlighted样式
            if adjustsButtonWhenHighlighted {
                if newValue {
                    alpha = 0.5
                } else {
                    alpha = 1.0
                }
            }

        }
        get { super.isHighlighted }
    }

    open override var isEnabled: Bool {
        set {
            super.isEnabled = newValue

            if !newValue, adjustsButtonWhenDisabled {
                alpha = 0.5
            } else {
                alpha = 1.0
            }
        }
        get { super.isEnabled }
    }

    open override func setImage(_ image: UIImage?, for state: UIControl.State) {
        var image = image
        if adjustsImageTintColorAutomatically {
            image = image?.withRenderingMode(.alwaysTemplate)
        }
        super.setImage(image, for: state)
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()

        updateTitleColorIfNeeded()
        if adjustsImageTintColorAutomatically {
            updateImageRenderingModeIfNeeded()
        }
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高
        // 系统 UIButton 不管任何时候，对 sizeThatFits:CGSizeZero 都会返回真实的内容大小，这里对齐
        var size = size
        if self.bounds.size.equalTo(size) || size.checkEmpty {
            size = CGSize.maxSize
        }

        let isImageViewShowing = (currentImage != nil)
        let isTitleLabelShowing = (currentTitle != nil || currentAttributedTitle != nil)
        var imageTotalSize = CGSize.zero // 包含 imageEdgeInsets 那些空间
        var titleTotalSize = CGSize.zero // 包含 titleEdgeInsets 那些空间
        // 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局
        let shouldCalculateSpacing =  isImageViewShowing && isTitleLabelShowing
        let spacingBetweenImageAndTitle = shouldCalculateSpacing ? spacingBetweenImageAndTitle.flat : 0

        let contetnInsets = contentEdgeInsets.removeFloatMin()
        var resultSize = CGSize.zero
        let contentLimitSize = CGSize(width: (size.width - contetnInsets.horizontalValue), height: (size.height - contetnInsets.verticalValue))

        switch imagePosition {
        case .top, .bottom:
            // 图片和文字上下排版时，宽度以文字或图片的最大宽度为最终宽度
            if isImageViewShowing {
                let imageLimitWidth = contentLimitSize.width - imageEdgeInsets.horizontalValue
                var imageSize = (imageView?.image != nil) ? imageView!.sizeThatFits(CGSize(width: imageLimitWidth, height: .greatestFiniteMagnitude)) : (currentImage?.size ?? .zero)
                imageSize.width = min(imageSize.width, imageLimitWidth) // sizeThatFits 时 self._imageView 为 nil 但 self.imageView 有值，而开启了 Bold Text 时，系统的 self.imageView sizeThatFits 返回值会比没开启 BoldText 时多 1pt（不知道为什么文字加粗与否会影响 imageView...），从而保证开启 Bold Text 后文字依然能完整展示出来，所以这里应该用 self.imageView 而不是 self._imageView
                imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.horizontalValue, height: imageSize.height + imageEdgeInsets.verticalValue);
            }

            if isTitleLabelShowing {
                let limitWidth = contentLimitSize.width - titleEdgeInsets.horizontalValue
                let limitHeight = contentLimitSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.verticalValue
                let titleLimitSize = CGSize(width: limitWidth, height: limitHeight)
                var titleSize = titleLabel?.sizeThatFits(titleLimitSize) ?? .zero
                titleSize.height = min(titleSize.height, limitHeight)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.horizontalValue, height: titleSize.height + titleEdgeInsets.verticalValue)
            }

            resultSize.width = contetnInsets.horizontalValue
            resultSize.width += max(imageTotalSize.width, titleTotalSize.width)
            resultSize.height = contetnInsets.verticalValue + imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height
        case .left, .right:
            // 图片和文字水平排版时，高度以文字或图片的最大高度为最终高度
            // 注意这里有一个和系统不一致的行为：当 titleLabel 为多行时，系统的 sizeThatFits: 计算结果固定是单行的，所以当 .Left 并且 titleLabel 多行的情况下, 计算的结果与系统不一致
            if isImageViewShowing {
                let limitHeight = contentLimitSize.height - imageEdgeInsets.verticalValue
                var imageSize = (imageView?.image != nil) ? imageView!.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: limitHeight)) : (currentImage?.size ?? .zero)
                imageSize.height = min(imageSize.height, limitHeight) // sizeThatFits 时 self._imageView 为 nil 但 self.imageView 有值，而开启了 Bold Text 时，系统的 self.imageView sizeThatFits 返回值会比没开启 BoldText 时多 1pt（不知道为什么文字加粗与否会影响 imageView...），从而保证开启 Bold Text 后文字依然能完整展示出来，所以这里应该用 self.imageView 而不是 self._imageView
                imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.horizontalValue, height: imageSize.height + imageEdgeInsets.verticalValue);
            }

            if isTitleLabelShowing {
                let limitWidth = contentLimitSize.width - titleEdgeInsets.horizontalValue - imageTotalSize.width - spacingBetweenImageAndTitle
                let limitHeight = contentLimitSize.height - titleEdgeInsets.verticalValue
                let titleLimitSize = CGSize(width: limitWidth, height: limitHeight)
                var titleSize = titleLabel?.sizeThatFits(titleLimitSize) ?? .zero
                titleSize.height = min(titleSize.height, limitHeight)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.horizontalValue, height: titleSize.height + titleEdgeInsets.verticalValue)
            }

            resultSize.width = contetnInsets.horizontalValue + imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
            resultSize.height = contetnInsets.verticalValue
            resultSize.height += max(imageTotalSize.height, titleTotalSize.height)
        }

        return resultSize
    }

    open override var intrinsicContentSize: CGSize {
        return sizeThatFits(.maxSize)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard !self.bounds.isEmpty else { return }

        let isImageViewShowing = (currentImage != nil)
        let isTitleLabelShowing = (currentTitle != nil || currentAttributedTitle != nil)

        var imageLimitSize = CGSize.zero
        var titleLimitSize = CGSize.zero
        var imageTotalSize = CGSize.zero // 包含 imageEdgeInsets 那些空间
        var titleTotalSize = CGSize.zero // 包含 titleEdgeInsets 那些空间

        // 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局
        let shouldCalculateSpacing =  isImageViewShowing && isTitleLabelShowing
        let spacingBetweenImageAndTitle = shouldCalculateSpacing ? self.spacingBetweenImageAndTitle.flat : 0

        var imageFrame = CGRect.zero
        var titleFrame = CGRect.zero

        let contentEdgeInsets = self.contentEdgeInsets.removeFloatMin()
        let contentSize = CGSize(width: self.bounds.width - contentEdgeInsets.horizontalValue, height: self.bounds.height - contentEdgeInsets.verticalValue)

        // 图片的布局原则都是尽量完整展示，所以不管 imagePosition 的值是什么，这个计算过程都是相同的
        if isImageViewShowing {
            imageLimitSize = CGSize(width: contentSize.width - imageEdgeInsets.horizontalValue, height: contentSize.height - imageEdgeInsets.verticalValue)

            var imageSize = (self._dr_imageView?.image != nil) ? self._dr_imageView!.sizeThatFits(imageLimitSize) : currentImage!.size
            imageSize.width = min(imageLimitSize.width, imageSize.width);
            imageSize.height = min(imageLimitSize.height, imageSize.height);
            imageFrame = CGRect.rectFrom(size: imageSize)
            imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.horizontalValue, height: imageSize.height + imageEdgeInsets.verticalValue)
        }

        // UIButton 如果本身大小为 (0,0)，此时设置一个 imageEdgeInsets 会让 imageView 的 bounds 错误，导致后续 imageView 的 subviews 布局时会产生偏移，因此这里做一次保护
        func makesureBoundsPositive(view: UIView?) {
            guard let view = view else { return }

            var bounds = view.bounds
            if bounds.minX < 0 || bounds.midY < 0 {
                bounds = CGRect.rectFrom(size: bounds.size)
                view.bounds = bounds
            }
        }

        if isImageViewShowing {
            makesureBoundsPositive(view: self._dr_imageView)
        }
        if isTitleLabelShowing {
            makesureBoundsPositive(view: self.titleLabel)
        }

        if [DrButtonImagePosition.top, .bottom].contains(imagePosition) {
            if isTitleLabelShowing {
                titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.horizontalValue, height: contentSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.verticalValue)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.width = min(titleLimitSize.width, titleSize.width);
                titleSize.height = min(titleLimitSize.height, titleSize.height);
                titleFrame = CGRect.rectFrom(size: titleSize)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.horizontalValue, height: titleSize.height + titleEdgeInsets.verticalValue)
            }

            switch contentHorizontalAlignment {
            case .left:
                imageFrame = isImageViewShowing ? imageFrame.resetX(contentEdgeInsets.left + imageEdgeInsets.left) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.resetX(contentEdgeInsets.left + titleEdgeInsets.left) : titleFrame
            case .center:
                imageFrame = isImageViewShowing ? imageFrame.resetX(contentEdgeInsets.left + imageEdgeInsets.left + imageLimitSize.width.floatCenter(for: imageFrame.width)) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.resetX(contentEdgeInsets.left + self.titleEdgeInsets.left + titleLimitSize.width.floatCenter(for: titleFrame.width)) : titleFrame
            case .right:
                imageFrame = isImageViewShowing ? imageFrame.resetX(self.bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.resetX(self.bounds.width - contentEdgeInsets.right - self.titleEdgeInsets.right - titleFrame.width) : titleFrame
            case .fill:
                if isImageViewShowing {
                    imageFrame = imageFrame.resetX(contentEdgeInsets.left + imageEdgeInsets.left)
                    imageFrame = imageFrame.resetWidth(imageLimitSize.width)
                }
                if (isTitleLabelShowing) {
                    titleFrame = titleFrame.resetX(contentEdgeInsets.left + titleEdgeInsets.left)
                    titleFrame = titleFrame.resetWidth(titleLimitSize.width);
                }
            default:
                break
            }

            if imagePosition == .top {
                switch contentVerticalAlignment {
                case .top:
                    imageFrame = isImageViewShowing ? imageFrame.resetY(contentEdgeInsets.top + imageEdgeInsets.top) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.resetY(contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top) : titleFrame
                    break;
                case .center:
                    let contentHeight = imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height
                    let minY = contentSize.height.floatCenter(for: contentHeight) + contentEdgeInsets.top
                    imageFrame = isImageViewShowing ? imageFrame.resetY(minY + imageEdgeInsets.top) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.resetY(minY + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top) : titleFrame
                case .bottom:
                    titleFrame = isTitleLabelShowing ? titleFrame.resetY(self.bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height) : titleFrame
                    imageFrame = isImageViewShowing ? imageFrame.resetY(self.bounds.height - contentEdgeInsets.bottom - titleTotalSize.height - spacingBetweenImageAndTitle - imageEdgeInsets.bottom - imageFrame.height) : imageFrame
                case .fill:
                    if isImageViewShowing, isTitleLabelShowing {
                        // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label
                        imageFrame = isImageViewShowing ? imageFrame.resetY(contentEdgeInsets.top + imageEdgeInsets.top) : imageFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.resetY(contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top) : titleFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.resetHeight(self.bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.minY) : titleFrame
                    } else if isImageViewShowing {
                        imageFrame = imageFrame.resetY(contentEdgeInsets.top + self.imageEdgeInsets.top)
                        imageFrame = imageFrame.resetHeight(contentSize.height - imageEdgeInsets.verticalValue)
                    } else {
                        titleFrame = titleFrame.resetY(contentEdgeInsets.top + self.titleEdgeInsets.top)
                        titleFrame = titleFrame.resetHeight(contentSize.height - titleEdgeInsets.verticalValue)
                    }
                default:
                    break
                }
            } else {
                switch contentVerticalAlignment {
                case .top:
                    titleFrame = isTitleLabelShowing ? titleFrame.resetY(contentEdgeInsets.top + titleEdgeInsets.top) : titleFrame
                    imageFrame = isImageViewShowing ? imageFrame.resetY(contentEdgeInsets.top + titleTotalSize.height + spacingBetweenImageAndTitle + imageEdgeInsets.top) : imageFrame
                case .center:
                    let contentHeight = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageAndTitle
                    let minY = contentSize.height.floatCenter(for: contentHeight) + contentEdgeInsets.top
                    titleFrame = isTitleLabelShowing ? titleFrame.resetY(minY + titleEdgeInsets.top) : titleFrame
                    imageFrame = isImageViewShowing ? imageFrame.resetY(minY + titleTotalSize.height + spacingBetweenImageAndTitle + imageEdgeInsets.top) : imageFrame
                case .bottom:
                    imageFrame = isImageViewShowing ? imageFrame.resetY(self.bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.resetY(self.bounds.height - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.bottom - titleFrame.height) : titleFrame
                case .fill:
                    if isImageViewShowing, isTitleLabelShowing {
                        // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label
                        imageFrame = imageFrame.resetY(self.bounds.height - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - imageFrame.height)
                        titleFrame = titleFrame.resetY(contentEdgeInsets.top + titleEdgeInsets.top)
                        titleFrame = titleFrame.resetHeight(self.bounds.height - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.bottom - titleFrame.minY)
                        
                    } else if isImageViewShowing {
                        imageFrame = imageFrame.resetY(contentEdgeInsets.top + imageEdgeInsets.top);
                        imageFrame = imageFrame.resetHeight(contentSize.height - imageEdgeInsets.verticalValue)
                    } else {
                        titleFrame = titleFrame.resetY(contentEdgeInsets.top + titleEdgeInsets.top)
                        titleFrame = titleFrame.resetHeight(contentSize.height - titleEdgeInsets.verticalValue)
                    }
                default:
                    break
                }
            }

            if isImageViewShowing {
                imageFrame = imageFrame.flatted()
                if let imgView = self._dr_imageView {
                    imgView.frame = imageFrame
                }
                self._dr_imageView?.frame = imageFrame
            }

            if (isTitleLabelShowing) {
                titleFrame = titleFrame.flatted()
                self.titleLabel!.frame = titleFrame;
            }
        }

        if [DrButtonImagePosition.left, .right].contains(imagePosition) {

            if isTitleLabelShowing {
                titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.horizontalValue - imageTotalSize.width - spacingBetweenImageAndTitle, height: contentSize.height - titleEdgeInsets.verticalValue)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.width = min(titleLimitSize.width, titleSize.width)
                titleSize.height = min(titleLimitSize.height, titleSize.height)
                titleFrame = CGRect.rectFrom(size:titleSize)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.horizontalValue, height: titleSize.height + titleEdgeInsets.verticalValue)
            }

            switch contentVerticalAlignment {
            case .top:
                imageFrame = isImageViewShowing ? imageFrame.resetY(contentEdgeInsets.top + imageEdgeInsets.top) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.resetY(contentEdgeInsets.top + titleEdgeInsets.top) : titleFrame
            case .center:
                imageFrame = isImageViewShowing ? imageFrame.resetY(contentEdgeInsets.top + contentSize.height.floatCenter(for: imageFrame.height) + imageEdgeInsets.top) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.resetY(contentEdgeInsets.top + contentSize.height.floatCenter(for: titleFrame.height) + titleEdgeInsets.top) : titleFrame
            case .bottom:
                imageFrame = isImageViewShowing ? imageFrame.resetY(self.bounds.height - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - imageFrame.height) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.resetY(self.bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height) : titleFrame
            case .fill:
                if isImageViewShowing {
                    imageFrame = imageFrame.resetY(contentEdgeInsets.top + imageEdgeInsets.top)
                    imageFrame = imageFrame.resetHeight(contentSize.height - imageEdgeInsets.verticalValue)
                }
                if isTitleLabelShowing {
                    titleFrame = titleFrame.resetY(contentEdgeInsets.top + titleEdgeInsets.top)
                    titleFrame = titleFrame.resetHeight(contentSize.height - titleEdgeInsets.verticalValue)
                }
            @unknown default:
                break
            }

            if imagePosition == .left {
                switch contentHorizontalAlignment {
                case .left:
                    imageFrame = isImageViewShowing ? imageFrame.resetX(contentEdgeInsets.left + imageEdgeInsets.left) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.resetX(contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left) : titleFrame
                case .center:
                    let contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
                    let minX = contentEdgeInsets.left + contentSize.width.floatCenter(for: contentWidth)
                    imageFrame = isImageViewShowing ? imageFrame.resetX(minX + imageEdgeInsets.left) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.resetX(minX + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left) : titleFrame
                case .right:
                    if imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width {
                        // 图片和文字总宽超过按钮宽度，则优先完整显示图片
                        imageFrame = isImageViewShowing ? imageFrame.resetX(contentEdgeInsets.left + imageEdgeInsets.left) : imageFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.resetX(contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left) : titleFrame
                    } else {
                        // 内容不超过按钮宽度，则靠右布局即可
                        titleFrame = isTitleLabelShowing ? titleFrame.resetX(self.bounds.width - contentEdgeInsets.right - titleEdgeInsets.right - titleFrame.width) : titleFrame
                        imageFrame = isImageViewShowing ? imageFrame.resetX(self.bounds.width - contentEdgeInsets.right - titleTotalSize.width - spacingBetweenImageAndTitle - imageTotalSize.width + self.imageEdgeInsets.left) : imageFrame
                    }
                case .fill:
                    if isImageViewShowing, isTitleLabelShowing {
                        // 同时显示图片和 label 的情况下，图片按本身宽度显示，剩余空间留给 label
                        imageFrame = imageFrame.resetX(contentEdgeInsets.left + imageEdgeInsets.left)
                        titleFrame = titleFrame.resetX(contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left)
                        titleFrame = titleFrame.resetWidth(self.bounds.width - contentEdgeInsets.right - self.titleEdgeInsets.right - titleFrame.minX)
                    } else if isImageViewShowing {
                        imageFrame = imageFrame.resetX(contentEdgeInsets.left + imageEdgeInsets.left)
                        imageFrame = imageFrame.resetWidth(contentSize.width - imageEdgeInsets.horizontalValue)
                    } else {
                        titleFrame = titleFrame.resetX(contentEdgeInsets.left + titleEdgeInsets.left)
                        titleFrame = titleFrame.resetWidth(contentSize.width - titleEdgeInsets.horizontalValue)
                    }
                default:
                    break
                }
            } else {
                switch contentHorizontalAlignment {
                case .left:
                    if imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width {
                        // 图片和文字总宽超过按钮宽度，则优先完整显示图片
                        imageFrame = isImageViewShowing ? imageFrame.resetX(self.bounds.width - contentEdgeInsets.right - self.imageEdgeInsets.right - imageFrame.width) : imageFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.resetX(self.bounds.width - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleTotalSize.width + titleEdgeInsets.left) : titleFrame
                    } else {
                        // 内容不超过按钮宽度，则靠左布局即可
                        titleFrame = isTitleLabelShowing ? titleFrame.resetX(contentEdgeInsets.left + titleEdgeInsets.left) : titleFrame
                        imageFrame = isImageViewShowing ? imageFrame.resetX(contentEdgeInsets.left + titleTotalSize.width + spacingBetweenImageAndTitle + imageEdgeInsets.left) : imageFrame
                    }
                case .center:
                    let contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
                    let minX = contentEdgeInsets.left + contentSize.width.floatCenter(for: contentWidth)
                    titleFrame = isTitleLabelShowing ? titleFrame.resetX(minX + titleEdgeInsets.left) : titleFrame
                    imageFrame = isImageViewShowing ? imageFrame.resetX(minX + titleTotalSize.width + spacingBetweenImageAndTitle + imageEdgeInsets.left) : imageFrame
                case .right:
                    imageFrame = isImageViewShowing ? imageFrame.resetX(self.bounds.width - contentEdgeInsets.right - self.imageEdgeInsets.right - imageFrame.width) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.resetX(self.bounds.width - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleEdgeInsets.right - titleFrame.width) : titleFrame
                case .fill:
                    if isImageViewShowing, isTitleLabelShowing {
                        // 图片按自身大小显示，剩余空间由标题占满
                        imageFrame = imageFrame.resetX(self.bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width)
                        titleFrame = titleFrame.resetX(contentEdgeInsets.left + titleEdgeInsets.left)
                        titleFrame = titleFrame.resetWidth(imageFrame.minX - imageEdgeInsets.left - spacingBetweenImageAndTitle - self.titleEdgeInsets.right - titleFrame.minX)
                    } else if isImageViewShowing {
                        imageFrame = imageFrame.resetX(contentEdgeInsets.left + imageEdgeInsets.left)
                        imageFrame = imageFrame.resetWidth(contentSize.width - imageEdgeInsets.horizontalValue)
                    } else {
                        titleFrame = titleFrame.resetX(contentEdgeInsets.left + titleEdgeInsets.left)
                        titleFrame = titleFrame.resetWidth(contentSize.width - titleEdgeInsets.horizontalValue)
                    }
                default:
                    break
                }
            }
            
            if (isImageViewShowing) {
                imageFrame = imageFrame.flatted()
                self._dr_imageView?.frame = imageFrame
            }
            if (isTitleLabelShowing) {
                titleFrame = titleFrame.flatted()
                self.titleLabel?.frame = titleFrame
            }
        }
    }
}

extension DrButton {

    func didInitialize() {
        // 默认接管highlighted和disabled的表现，去掉系统默认的表现
        self.adjustsImageWhenHighlighted = false
        self.adjustsImageWhenDisabled = false
    }

    // 系统访问 self.imageView 会触发 layout，而私有方法 _imageView 则是简单地访问 imageView，所以在 QMUIButton layoutSubviews 里应该用这个方法
    private var _dr_imageView: UIImageView? {
        let pSelector = NSSelectorFromString("_imageView")
        if self.canPerformAction(pSelector, withSender: self),
           let imgView = self.perform(pSelector).takeUnretainedValue() as? UIImageView
        {
            return imgView
        }

        return imageView
    }

    func adjustsButtonHighlighted() {
        if let color1 = highlightedBackgroundColor {
            highlightedBackgroundLayer.frame = bounds
            highlightedBackgroundLayer.cornerRadius = layer.cornerRadius
            //highlightedBackgroundLayer.qmui_maskedCorners = self.layer.qmui_maskedCorners
            highlightedBackgroundLayer.backgroundColor = self.isHighlighted ? color1.cgColor : UIColor.clear.cgColor
        }

        if let color2 = self.highlightedBorderColor {
            layer.borderColor = self.isHighlighted ? color2.cgColor : originBorderColor.cgColor;
        }
    }

    func updateTitleColorIfNeeded() {
        if adjustsTitleTintColorAutomatically, currentTitle != nil {
            setTitleColor(tintColor, for: .normal)
        }

        if adjustsTitleTintColorAutomatically, let attStr = currentAttributedTitle {
            let mutAttrStr = NSMutableAttributedString.init(attributedString: attStr)
            mutAttrStr.addAttribute(.foregroundColor, value: tintColor!, range: NSRange(location: 0, length: mutAttrStr.length))
            setAttributedTitle(mutAttrStr, for: .normal)
        }
    }

    func updateImageRenderingModeIfNeeded() {
        let hAndS: UIControl.State = [.selected, .highlighted]
        let status: [UIControl.State] = [.normal, .highlighted, .selected, hAndS, .disabled]

        for statu in status {
            let image = image(for: statu)
            guard let image = image else {  return }

            if adjustsImageTintColorAutomatically {
                setImage(image, for: statu)
            } else {
                setImage(image.withRenderingMode(.alwaysOriginal), for: statu)
            }
        }
    }
}

extension CGFloat {
    func removeFloatMin() -> CGFloat {
        return self == CGFloat.leastNormalMagnitude ? 0 : self
    }

    func floatCenter(for child: CGFloat) -> CGFloat {
        return ((self - child) / 2.0).flat
    }

    var flat: CGFloat {
        return self.flatSpecificScale(0)
    }

    func flatSpecificScale(_ scale: CGFloat) -> CGFloat {
        let floatValue = self.removeFloatMin()
        let scale = scale != 0 ? scale : UIScreen.main.scale
        let flattedValue = ceil(floatValue * scale) / scale
        return flattedValue
    }
}

extension CGSize {
    static var maxSize: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }

    var checkEmpty: Bool {
        return self.width <= 0 || self.height <= 0
    }
}

extension CGRect {
    static func rectFrom(size: CGSize) -> CGRect {
        return CGRect(origin: .zero, size: size)
    }

    func flatted() -> CGRect {
        let originX = origin.x.flat
        let originY = origin.y.flat
        return CGRect(x: originX, y: originY, width: width.flat, height: height.flat)
    }

    func resetY(_ y: CGFloat) -> CGRect {
        return CGRect(x: minX, y: y.flat, width: width, height: height)
    }

    func resetX(_ x: CGFloat) -> CGRect {
        return CGRect(x: x.flat, y: minY, width: width, height: height)
    }

    func resetWidth(_ w: CGFloat) -> CGRect {
        return CGRect(x: minX, y: minY, width: w.flat, height: height)
    }

    func resetHeight(_ h: CGFloat) -> CGRect {
        return CGRect(x: minX, y: minY, width: width, height: h.flat)
    }
}

extension UIEdgeInsets {

    func removeFloatMin() -> UIEdgeInsets {
        let resultTop = top == CGFloat.leastNormalMagnitude ? 0 : top
        let resultLeft = self.left == CGFloat.leastNormalMagnitude ? 0 : self.left
        let resultBottom = bottom == CGFloat.leastNormalMagnitude ? 0 : bottom
        let resultRight = self.right == CGFloat.leastNormalMagnitude ? 0 : self.right

        return UIEdgeInsets(top: resultTop, left: resultLeft, bottom: resultBottom, right: resultRight)
    }

    var horizontalValue: CGFloat {
        return self.left + self.right
    }

    var verticalValue: CGFloat {
        return self.top + self.bottom
    }
}
