//
/*
* ****************************************************************
*
* 文件名称 : DateUtil
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 7:59 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import Foundation

public struct DateUtil {

    static func jjShowTimeFormTimestampString(_ value: String) -> String {
        return jjShowTimeToNow(from: timeIntervalFormTimestampString(value))
    }

    static func dateFormTimestampString(_ value: String) -> Date {
        if let timestamp = Double(value) {
            // FIXME: - 判断标准有点差劲👎🏻,不过用到手机报废不成问题🙃!
            if timestamp > Double(Int32.max) {
                /// 以毫秒为单位
                return Date(timeIntervalSince1970: timestamp / 1000)
            } else {
                /// 秒为单位
                return Date(timeIntervalSince1970: timestamp)
            }
        }
        return Date()
    }

    static func timeIntervalFormTimestampString(_ value: String) -> Double {
        if let timestamp = Double(value) {
            // FIXME: - 判断标准有点差劲👎🏻,不过用到手机报废不成问题🙃!
            if timestamp > Double(Int32.max) {
                /// 以毫秒为单位
                return timestamp / 1000
            } else {
                /// 秒为单位
                return timestamp
            }
        }
        return 0
    }

    static func jjShowTimeToNow(from timeInterval: Double) -> String {
        let nowTimeInterval = ceil(Date().timeIntervalSince1970)
        var difference = nowTimeInterval - timeInterval
        // FIXED: - 不可能出现, 后台审核时间大于3分钟
        if difference < 60 {
            return "刚刚"
        }

        difference /= 60
        if difference < 60 {
            return "\(lrint(floor(difference)))分钟前"
        }

        difference /= 60
        if difference < 24 {
            return "\(lrint(floor(difference)))小时前"
        }

        difference /= 24
        if difference < 30 {
            return "\(lrint(floor(difference)))天前"
        }

        difference /= 30
        if difference < 12 {
            return "\(lrint(floor(difference)))月前"
        }

        difference /= 12
        return "\(lrint(floor(difference)))年前"
    }
}
