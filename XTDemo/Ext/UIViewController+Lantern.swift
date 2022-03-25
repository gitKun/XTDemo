//
/*
* ****************************************************************
*
* 文件名称 : UIViewController+Lantern
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:25 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import Kingfisher
import Photos
import Lantern

extension UIViewController {
  func topPresentedViewController() -> UIViewController {
    var topVC = self
    while let presentVC = topVC.presentedViewController {
      topVC  = presentVC
    }
    return topVC
  }
}

private class XTAnimatedImageView: AnimatedImageView {
    
    public var imageDidChangedHandler: (() -> ())?

    public override var image: UIImage? {
        didSet {
            imageDidChangedHandler?()
        }
    }
}


//private class XTPhotoBrowserCell: LanternImageCell {
//
//    required init(frame: CGRect) {
//        super.init(frame: frame)
//        let containeView = imageView.superview
//        imageView.removeFromSuperview()
//        imageView = {
//            // FIXED: 使用 Kingfisher.AnimatedImageView 解决内存暴涨问题(使用离屏渲染)
//            let imgView = XTAnimatedImageView(frame: .zero)
//            imgView.clipsToBounds = true
//            return imgView
//        }()
//        containeView?.addSubview(imageView)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented!")
//    }
//}

/// 跳出相册
extension UIViewController {

  func showXTPhotoBrowser(from sourceView: UIView, imagesUrl: [URL], selsctIndex: Int) {

    guard !imagesUrl.isEmpty else { return }
    let orgImageUrlArray = imagesUrl
    let imageView = sourceView
    let browser = Lantern()
    browser.numberOfItems = {
      orgImageUrlArray.count
    }

      /*
       browser.cellClassAtIndex = { _ in
       return LanternImageCell.self
       }
       */

    browser.reloadCellAtIndex = { context in
        guard let lanternCell = context.cell as? LanternImageCell else { return }

        let url = orgImageUrlArray[context.index]
        lanternCell.imageView.kf.setImage(with: url, placeholder: nil)

        // 添加长按事件
        lanternCell.longPressedAction = { cell, /*logGest*/ _ in
            cell.lantern?.showSaveActionSheet(cell: cell, from: cell.lantern)
        }
    }

    // Zoom动画
      browser.transitionAnimator = LanternSmoothZoomAnimator(transitionViewAndFrame: { (index, destinationView) -> LanternSmoothZoomAnimator.TransitionViewAndFrame? in
          guard let imageViewArray = imageView.superview?.subviews,
                index < imageViewArray.count,
                let imgView = imageViewArray[index] as? UIImageView else {
                    return nil
                }
          let image = imgView.image
          let transitionView = UIImageView(image: image)
          transitionView.contentMode = imageView.contentMode
          transitionView.clipsToBounds = true
          let thumbnailFrame = imgView.convert(imgView.bounds, to: destinationView)
          return (transitionView, thumbnailFrame)
      })
      browser.pageIndex = selsctIndex
      browser.show()
  }

    func showSaveActionSheet(cell: LanternImageCell, from: UIViewController?) {
        guard let image = cell.imageView.image else {
            showToast("暂无相片可保存!")
            return
        }

        let alertVC = UIAlertController.init(title: nil, message: "选择操作", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction.init(title: "保存", style: .default) { _ in
            self.saveImage(image: image)
        }

        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(saveAction)
        alertVC.addAction(cancelAction)
        let current = from ?? self.presentedViewController
        if let current = current {
            current.present(alertVC, animated: true, completion: nil)
        }
    }

    func saveImage(image: UIImage) {

        var data = image.kf.data(format: .GIF)
        if data == nil {
            data = image.kf.data(format: .PNG)
        } else if data == nil {
            data = image.kf.data(format: .JPEG)
        } else if data == nil {
            data = image.kf.data(format: .unknown)
        }

        guard let saveData = data else {
            self.toast.showCenter(message: "图片解码失败!")
            return
        }

        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: saveData, options: nil)
        },completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    self.toast.showCenter(message: "保存成功")
                } else if let error = error {
                    self.toast.showCenter(message: "保存失败:\(error.localizedDescription)")
                }
            }
        })
    }
}
