#
# Be sure to run `pod lib lint demo-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                  = 'DIMP'
    s.version               = '0.1.0'
    s.summary               = 'DIMPLES'
    s.description           = <<-DESC
            DIMP Libraries for Easy Startup
                              DESC
    s.homepage              = 'https://github.com/dimchat/demo-objc'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Albert Moky' => 'albert.moky@gmail.com' }
    s.source                = { :git => 'https://github.com/dimchat/demo-objc.git', :tag => s.version.to_s }
    # s.platform            = :ios, "11.0"
    s.ios.deployment_target = '12.0'

    s.source_files          = 'Classes', 'Classes/**/*.{h,m}'
    # s.exclude_files       = 'Classes/Exclude'
    s.public_header_files   = 'Classes/**/*.h'

    # s.frameworks          = 'Security'
    # s.requires_arc        = true

    s.dependency 'DIMSDK', '~> 0.6.2'
    s.dependency 'DIMCore', '~> 0.6.0'
    s.dependency 'DaoKeDao', '~> 0.6.2'
    s.dependency 'MingKeMing', '~> 0.6.1'

    s.dependency 'FiniteStateMachine', '~> 1.0'
    # s.dependency 'MarsGate'
end
