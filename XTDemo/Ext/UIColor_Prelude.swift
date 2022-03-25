//
/*
* ****************************************************************
*
* 文件名称 : UIColor_Prelude
* 作   者 : Created by 坤
* 创建时间 : 2022/3/11 9:25 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/11 初始版本
*
* ****************************************************************
*/

import UIKit

// MARK: - HEX

public extension UIColor {

    @nonobjc static func hexa(_ value: UInt32) -> UIColor {
        let a = CGFloat((value & 0xFF000000) >> 24) / 255.0
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0xFF00) >> 8) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    @nonobjc static func hex(_ value: UInt32) -> UIColor {
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0xFF00) >> 8) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    @nonobjc static var randomWithoutAlpha: UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }

    var hexString: String {
        guard let components = self.cgColor.components else { return "000000" }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    /*
     public static func color(hexValue: String, alpha: Float) -> UIColor {
     var cString:String = hexValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased();
     
     if cString.hasPrefix("0x") {
     cString = (cString as NSString).substring(from: 2);
     }
     
     if cString.hasPrefix("#") {
     cString = (cString as NSString).substring(from: 1);
     }
     
     if cString.count == 3 {
     var result = ""
     //只传入了三个数字比如000，需要转换为000000
     for num in cString {
     result.append(num)
     result.append(num)
     }
     //合并数据
     cString = result
     }
     
     if cString.count != 6 {
     return UIColor.gray;
     }
     
     let rString = (cString as NSString).substring(to: 2)
     let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
     let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
     
     var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
     Scanner(string: rString).scanHexInt32(&r)
     Scanner(string: gString).scanHexInt32(&g)
     Scanner(string: bString).scanHexInt32(&b)
     
     return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
     }
     
     public static func color(hexString: String) -> UIColor {
     return color(hexValue: hexString, alpha: 1.0);
     }
     */
}

// MARK: - rgb

public extension UIColor {

    @nonobjc static func rgba(r: Float, g: Float, b: Float, a: Float = 1.0) -> UIColor {
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: CGFloat(a))
    }
}

// MARK: - Mixing

extension UIColor {

    public func mixLighter(_ amount: CGFloat) -> UIColor {
        return self.mix(with: .hex(0xFFFFFF), amount: amount)
    }

    public func mixDarker(_ amount: CGFloat) -> UIColor {
        return self.mix(with: .hex(0x000000), amount: amount)
    }

    private func mix(with color: UIColor, amount: CGFloat) -> UIColor {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var alpha1: CGFloat = 0
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var alpha2: CGFloat = 0

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &alpha1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &alpha2)

        return UIColor(
            red: r1 * (1.0 - amount) + r2 * amount,
            green: g1 * (1.0 - amount) + g2 * amount,
            blue: b1 * (1.0 - amount) + b2 * amount,
            alpha: alpha1
        )
    }
}
