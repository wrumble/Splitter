# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Splitter' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

    pod 'TesseractOCRiOS', '4.0.0'
    pod 'WDImagePicker', :git => 'https://github.com/justwudi/WDImagePicker.git', :tag => '0.2.2'
    pod 'GooglePlaces'
    pod 'Stripe'
    pod 'CardIO'
    pod 'AFNetworking', '~> 3.0'
    pod 'NVActivityIndicatorView'
    pod 'DeviceKit', '~> 1.0'
    pod 'iCarousel'
    pod 'IQKeyboardManagerSwift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
