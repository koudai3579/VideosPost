# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'VideosPost' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VideosPost
pod 'FirebaseMessaging'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Nuke'
#pod 'PKHUD'
#pod 'Charts'
#pod 'SCLAlertView'
#pod 'SCLAlertView-Objective-C'
#pod 'DGCharts'
#pod 'ChartsRealm'
#pod 'FirebaseAnalytics'

end

#XCODEのバージョンを15に上げたときの解決策　以下を追加
post_install do |installer|
  xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Xcode 15以上で動作します(if内を追記)
      if config.base_configuration_reference && Integer(xcode_base_version) >= 15
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end
  end
end
