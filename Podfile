platform :ios, '10.0'
use_frameworks!

def testing_pods
  pod 'RxSwift'
  pod 'Quick'
  pod 'Nimble'
  pod 'RxNimble', subspecs: ['RxBlocking', 'RxTest']
  pod 'Sourcery'
end

target '{PROJECT_NAME}' do
  pod 'NimbleExtension', :git => 'https://github.com/nimblehq/NimbleExtension', :branch => 'master'

  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxAlamofire'
  pod 'SnapKit'
  pod 'SwiftLint'
  pod 'R.swift'
  pod 'KeychainAccess'
  pod 'Kingfisher'
  pod 'IQKeyboardManagerSwift'
  pod 'Wormholy'
  
  pod 'Firebase/Crashlytics'

  target '{PROJECT_NAME}Tests' do
    inherit! :search_paths
    testing_pods
  end

  target '{PROJECT_NAME}UITests' do
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
