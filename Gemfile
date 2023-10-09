source "https://rubygems.org"

gem 'arkana'
gem "cocoapods"
gem "fastlane"
gem "xcov"
gem "danger"
gem "danger-swiftlint"
gem "danger-xcode_summary"
gem 'danger-swiftformat'
gem 'danger-xcov'
# Fix issue with Cocoapods 13.0 when activesupport is 7.1.0
gem 'activesupport', '~> 7.0.0', '>= 7.0.8'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
