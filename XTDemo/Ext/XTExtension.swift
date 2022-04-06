//
/*
* ****************************************************************
*
* 文件名称 : XTExtension
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:33 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit

extension String {

    var base64Encoding: String {
        let plainData = Data(self.utf8)
        let base64String = plainData.base64EncodedString(/*options: .init(rawValue: 0)*/)
        return base64String
    }

    var base64Decoding: String {
        guard let decodedData = Data.init(base64Encoded: self, options: .ignoreUnknownCharacters) else { return "" }

        let decodedString = String(decoding: decodedData, as: UTF8.self)
        return decodedString
    }
}

extension UIColor {

    enum XiTu {
        static let main1: UIColor = UIColor.hex(0x1e80ff)
        static let cellBg: UIColor = UIColor.hex(0xF7F7F7)
        static let cellContenBg: UIColor = .white
        static let nickName: UIColor = .hex(0x1D2129)
        static let position: UIColor = .hex(0x8A919F)
        static let shortContent: UIColor = .hex(0x4E5969)
        static let hotSortBg: UIColor = .hex(0xF7F8FA)
        static let hotShortZan: UIColor = .hex(0x007FFF)
        static let hotCommentIcon: UIColor = .rgba(r: 255, g: 131, b: 78)
        static let hotCommentContent: UIColor = .hex(0x4E5969)
        static let circleTagBG: UIColor = .hex(0xE8F3FF)
        static let circleTagTitle: UIColor = .hex(0x252933)
        static let commentCount: UIColor = .hex(0x86909C)

        /// 点赞人头像的 border
        static let digAvatarBorder: UIColor = .hex(0xFFFFFF)

        /// 点赞人数
        static let digCount: UIColor = .hex(0xC2C8D1)

        static let unreadBg: UIColor = .hex(0x606060)

    }
}

extension UIEdgeInsets {
    
    struct Direction: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let top: Direction = Direction(rawValue: 1 << 0)
        public static let left: Direction = Direction(rawValue: 1 << 1)
        public static let bottom: Direction = Direction(rawValue: 1 << 2)
        public static let right: Direction = Direction(rawValue: 1 << 3)

        public static let horizontal: Direction = [Direction.left, Direction.right]
        public static let vertical: Direction = [Direction.top, Direction.bottom]
    }

    static func only(_ dir: Direction, value: CGFloat) -> UIEdgeInsets {
        switch dir {
        case .top:
            return .init(top: value, left: 0, bottom: 0, right: 0)
        case .left:
            return .init(top: 0, left: value, bottom: 0, right: 0)
        case .bottom:
            return .init(top: 0, left: 0, bottom: value, right: 0)
        case .right:
            return .init(top: 0, left: 0, bottom: 0, right: value)
        case .horizontal:
            return .init(top: 0, left: value, bottom: 0, right: value)
        case .vertical:
            return .init(top: value, left: 0, bottom: value, right: 0)
        default:
            return .zero
        }
    }

    static func all(_ value: CGFloat) -> UIEdgeInsets {
        return .init(top: value, left: value, bottom: value, right: value)
    }
}
