source 'https://rubygems.org'

gemspec

gem 'xcodeproj', :git => 'https://github.com/CocoaPods/Xcodeproj.git', :ref => '83bd2413942c6d99836722b41807a8f5cdb16269'

gem 'rake'
gem 'webmock'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
