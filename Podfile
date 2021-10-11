platform :ios, '10.0'
use_frameworks!

def testing_pods
  pod 'Quick'
  pod 'Nimble'
  pod 'RxNimble', subspecs: ['RxBlocking', 'RxTest']
  pod 'RxSwift'
  pod 'Sourcery'
  pod 'SwiftFormat/CLI'
end

target 'AddDanger' do
  # UI
  # pod 'Kingfisher'
  pod 'SnapKit'

  # Rx
  pod 'RxAlamofire'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxSwift'

  # Storage
  # pod 'KeychainAccess'

  # Tools
  pod 'Firebase/Crashlytics'
  pod 'IQKeyboardManagerSwift'
  pod 'NimbleExtension', :git => 'https://github.com/nimblehq/NimbleExtension', :branch => 'master'
  pod 'R.swift'

  # Development
  pod 'SwiftLint'
  pod 'Wormholy', :configurations => ['Debug Staging', 'Debug Production']

  target 'AddDangerTests' do
    inherit! :search_paths
    testing_pods
  end

  target 'AddDangerUITests' do
    testing_pods
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
