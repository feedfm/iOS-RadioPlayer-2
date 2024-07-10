
target 'iOS-RadioPlayer-2' do
  platform :ios, '12.4'
  use_frameworks!
  pod 'OAStackView'
  pod 'FSQCollectionViewAlignedLayout'
  pod 'FFCircularProgressView'
  pod 'FeedMedia', '~> 5.6.0'
end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.4'
            end
        end
    end
end
