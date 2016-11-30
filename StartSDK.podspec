Pod::Spec.new do |spec|
    spec.name = 'StartSDK'
    spec.version = '0.2.1'
    spec.license = { :type => 'MIT', :file => 'LICENSE' }
    spec.homepage = 'https://github.com/payfort/start-ios-sdk'
    spec.authors = { 'drif' => 'drif@mail.ru' }
    spec.summary = 'This iOS SDK makes it easy for developers to accept payments inside mobile application.'
    spec.source = { :git => 'https://github.com/payfort/start-ios-sdk.git', :tag => "v#{spec.version}" }
    spec.platform = :ios, '8.0'
    spec.source_files = 'StartSDK/StartSDK/**/*.{h,m}'
    spec.public_header_files = 'StartSDK/StartSDK/Models/{Start,StartCard,StartToken}.h'
end
