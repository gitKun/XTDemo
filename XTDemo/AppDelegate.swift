//
/*
* ****************************************************************
*
* 文件名称 : AppDelegate
* 作   者 : Created by 坤
* 创建时间 : 2022/3/23 4:29 PM
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/3/23 初始版本
*
* ****************************************************************
*/

import UIKit
import Nuke


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        debugPrint(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? "Document path => Error! ____#")

        appearanceSetting()
        Nuke.ImagePipeline.shared = Nuke.ImagePipeline(configuration: .withDataCache)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension AppDelegate {

    func appearanceSetting() {

        UITextField.appearance().tintColor = .rgba(r: 88, g: 158, b: 255)

        // FIXED: - 2022.03.11 iOS15
        if #available(iOS 13.0, *) {
            //UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
            // 导航栏
            do {
                let titleAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.rgba(r: 51, g: 51, b: 51), .font: UIFont.systemFont(ofSize: 18, weight: .medium)]
                let app = UINavigationBarAppearance.init()
                app.configureWithOpaqueBackground()  // 重置背景和阴影颜色
                app.titleTextAttributes = titleAttr
                app.backgroundColor = UIColor.white  // 设置导航栏背景色
                //app.backgroundImage = UIImage.getImage(color: UIColor.white, size: CGSize(width: 1, height: 1))
                app.shadowImage = UIImage.init()  // 设置导航栏下边界分割线透明
                UINavigationBar.appearance().scrollEdgeAppearance = app  // 带scroll滑动的页面
                UINavigationBar.appearance().standardAppearance = app // 常规页面
            }

            // FIXED: - tableView 解决 iOS15 部分情况下 tableView sectionHeaderTopPadding 设置成 0 也不起作用的 BUG
            UITableView.appearance().tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))

            if #available(iOS 15.0, *) {
                UITableView.appearance().sectionHeaderTopPadding = 0
                UITableView.appearance().isPrefetchingEnabled = false
            }
        }
    }
}
