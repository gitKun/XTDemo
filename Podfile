# Uncomment the next line to define a global platform for your project

platform :ios, '13.1'
use_frameworks!
inhibit_all_warnings!

target 'XTDemo' do
  # Comment the next line if you don't want to use dynamic frameworks

  # Pods for XTDemo

  # '15.0.0'
  pod 'Moya/Combine'
  
  # 缓存数据 '6.0.0'
  pod 'Cache'

  # 下拉刷新
  pod 'MJRefresh'

  # 5.0.1
  pod 'Toast-Swift'

  # 1.1.2
  pod 'Lantern'

  # 10.7.1
  pod 'Nuke'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.1'
    end
  end
end
