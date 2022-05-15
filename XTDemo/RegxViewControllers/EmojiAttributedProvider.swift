//
/*
* ****************************************************************
*
* 文件名称 : EmojiAttributedProvider
* 作   者 : Created by 坤
* 创建时间 : 2022/3/24 8:04 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/24 初始版本
*
* ****************************************************************
*/

import Foundation
import UIKit

private struct EmojiModel: Codable {
    let emojiDes: String
    let imageName: String
}

fileprivate extension String {

    func emojiSubString(_ range: Range<Int>) -> String {
        let start = index(self.startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) ?? startIndex
        let end = index(start, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex

        return String(self[start..<end])
    }

    func themeSubString(_ range: Range<Int>) -> String {
        let themeWrapped = emojiSubString(range)

        let strList = themeWrapped.split(separator: "#")
        guard strList.count > 2 else { return themeWrapped }

        return "#" + String(strList[1]) + "#"
    }
}

class EmojiAttributedProvider {

    static let shared: EmojiAttributedProvider = .init()

    private var emojiModels: [EmojiModel] = []
    private var emojiDesRegx: NSRegularExpression!
    private var themeRegx: NSRegularExpression!

    private init() {
        self.setupRegularExpressions()
        self.loadEmojiInfo()
    }
}

// MARK: - Regx

extension EmojiAttributedProvider {

    private func setupRegularExpressions() {
        let regexOp = NSRegularExpression.Options.caseInsensitive

        do {
            emojiDesRegx = try NSRegularExpression(
                pattern: #"\[[\u4e00-\u9fa5]{1,9}\]"#,//"\\[[u4e00-u9fa5]{1,6}\\]",
                options:regexOp
            )

            themeRegx = try NSRegularExpression(
                pattern: #"\[\d{5,}#[\u4e00-\u9fa5]{1,}#]"#,
                options: regexOp
            )
        } catch {
            print(error.localizedDescription)
        }
    }

    func generateEmojiAttributedString(from string: String, attributed: [NSAttributedString.Key: Any], imageHeihg: CGFloat) -> NSAttributedString {

        let resultAttStr = NSMutableAttributedString(string: string, attributes: attributed)

        guard let _ = emojiDesRegx else { return resultAttStr }

        let emojiResults = emojiDesRegx.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))

        let rangAndDesList: [(NSRange, String)] = emojiResults.map { result in
            let range = result.range
            let emojiDes = string.emojiSubString(range.lowerBound..<range.upperBound)
            return (result.range, emojiDes)
        }.reversed()

        for rangAndDes in rangAndDesList {
            guard let emojiImg = loadImageFromEmojiDes(rangAndDes.1) else { continue }

            let imageAttachmen = NSTextAttachment()
            imageAttachmen.image = emojiImg
            imageAttachmen.bounds = CGRect(x: 0, y: -3, width: imageHeihg, height: imageHeihg)
            let imageAttStr = NSAttributedString(attachment: imageAttachmen)

            resultAttStr.replaceCharacters(in: rangAndDes.0, with: imageAttStr)
        }

        guard let _ = themeRegx else { return resultAttStr }

        let processString = resultAttStr.string
        let themeResults = themeRegx.matches(in: processString, options: [], range: NSRange(location: 0, length: processString.count))
        let themeList: [(NSRange, String)] = themeResults.map { result in
            let theme = processString.themeSubString(result.range.lowerBound..<result.range.upperBound)
            return (result.range, theme)
        }.reversed()

        var themeAttr = attributed
        themeAttr[.foregroundColor] = UIColor.XiTu.main1
        for theme in themeList {
            let themeAttStr = NSAttributedString(string: theme.1, attributes: themeAttr)

            resultAttStr.replaceCharacters(in: theme.0, with: themeAttStr)
        }

        return resultAttStr
    }
}


// MARK: - Load image

extension EmojiAttributedProvider {

    func loadImageFromEmojiDes(_ des: String) -> UIImage? {
        var imageName = ""
        for item in self.emojiModels {
            if item.emojiDes == des {
                imageName = item.imageName
                break
            }
        }

        return self.loadImage(wiht: imageName)
    }

    private func loadEmojiInfo() {
        // Bundle.main.path(forResource: "emoji_all.plist", ofType: nil, inDirectory: "emoji")
        guard let emojiInfoUrl = Bundle.main.url(forResource: "emoji_all.plist", withExtension: nil, subdirectory: "emoji") else {
            print("Emoji info plist file path not found!")
            return
        }

        do {
            let data = try Data(contentsOf: emojiInfoUrl)
            let resault = try PropertyListDecoder().decode([EmojiModel].self, from: data)
            self.emojiModels = resault
        } catch {
            print(error.localizedDescription)
        }
    }

    private func loadImage(wiht name: String) -> UIImage? {
        let emojiPath = Bundle.main.bundleURL.appendingPathComponent("emoji")
        let imagePath = emojiPath.appendingPathComponent("\(name).png")

        return UIImage(contentsOfFile: imagePath.path)
    }
}
