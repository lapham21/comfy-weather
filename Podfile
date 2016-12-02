source 'https://github.com/CocoaPods/Specs'

platform :ios, '9.0'
use_frameworks!

target 'ComfyWeather' do
  pod 'Alamofire', '~> 4.0'
  pod 'AlamofireImage', '~> 3.0'
  pod 'Genome', '~> 3.0'
  pod 'RealmSwift', '~> 1.1.0'
  pod 'FacebookCore', '~> 0.2.0'
  pod 'FacebookLogin', '~> 0.2.0'
  pod 'FacebookShare', '~> 0.2.0'
  pod 'RxSwift', '~> 3.0.0-beta.2'
  pod 'RxCocoa', '~> 3.0.0-beta.2'

  target 'ComfyWeatherTests' do
      inherit! :search_paths

      pod 'OHHTTPStubs'
      pod 'OHHTTPStubs/Swift'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
