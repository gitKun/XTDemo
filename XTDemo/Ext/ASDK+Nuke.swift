//
/*
* ****************************************************************
*
* 文件名称 : ASDK+Nuke
* 作   者 : Created by 坤
* 创建时间 : 2022/4/7 22:10
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/7 初始版本
*
* ****************************************************************
*/

import Foundation
import Nuke
import AsyncDisplayKit


extension ImageRequest {

    /// default size: (111, 111)
    static func jjListImageRequest(with url: URL?, size: CGSize) -> ImageRequest {
        let processors: [ImageProcessing] = [
            ImageProcessors.Resize(size: size, unit: .points, contentMode: .aspectFit, crop: true, upscale: false)
        ]
        let request = ImageRequest(url: url, processors: processors, priority: .normal, userInfo: nil)

        return request
    }

    /// default width: 40
    static func jjListAvatarImageRequest(with url: URL?, width: CGFloat) -> ImageRequest {
        let processors: [ImageProcessing] = [
            ImageProcessors.Resize(size: CGSize(width: width, height: width), unit: .points, contentMode: .aspectFit, crop: true, upscale: false),
            ImageProcessors.Circle(border: nil)
        ]
        let request = ImageRequest(url: url, processors: processors)

        return request
    }
}



extension ASImageNode {

    public func setImage(
        with request: ImageRequest,
        placeholder: UIImage? = nil,
        failureImage: UIImage? = nil,
        progress: ((_ response: ImageResponse?, _ completed: Int64, _ total: Int64) -> Void)? = nil
    ) {
        if let image = ImagePipeline.shared.cache.cachedImage(for: request) {
            self.image = image.image
            return
        }

        ImagePipeline.shared.loadImage(with: request, progress: progress) { [weak self] result in
            switch result {
            case .success(let response):
                let image = response.image
                self?.image = image
                ImagePipeline.shared.cache.storeCachedImage(.init(image: image), for: request)
            case .failure(let error):
                print(error.localizedDescription)
                self?.image = failureImage ?? placeholder
            }
        }
    }
}

/*
// Nuke 仅支持 UIView
// Nuke.loadImage(with:into:) 方法有 mainThread 检查,不符合 Texture 子线程的设定
extension ASImageNode: Nuke_ImageDisplaying {

    public func nuke_display(image: PlatformImage?, data: Data?) {
        self.image = image
    }

    func testShow() {
        Nuke.loadImage(with: "https://www.xc.com/sad.png", into: self)
    }
}
*/
